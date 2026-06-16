import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/control/data/crypto/ble_control_crypto.dart';
import 'package:smart_curtain_app/features/control/domain/entities/ble_control_result.dart';
import 'package:smart_curtain_app/features/pairing/data/crypto/hex_utils.dart';

void main() {
  final crypto = BleControlCrypto();

  // Fixed session key (khớp pairing-crypto-test reference: PSK=0xAA, nonce=0x00).
  final sessionKey = Uint8List.fromList(HexUtils.decode(
      '08df2a1f3972b6157fbbc66434f520d5ba24d64657fe66d0fc2f784d097a9bfa'));

  group('BleControlCrypto — wire format v2 §5.2 (commit ab34570d)', () {
    test('wire layout = [counter:8][ciphertext+tag] (NO IV field)', () {
      const counter = 1;
      final plain = utf8.encode('{"cmd":"open"}');
      final frame = crypto.encryptCommand(
        sessionKey: sessionKey,
        counter: counter,
        plaintext: plain,
      );
      // 8 counter + plaintext + 8 tag (CTR-mode CCM → ct len = plaintext len)
      expect(frame.length, 8 + plain.length + 8);

      // Counter ở 8 byte đầu, big-endian
      expect(frame.sublist(0, 8), Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 1]));
      // KHÔNG có IV bytes ở giữa — ciphertext start ngay sau counter
    });

    test('round-trip decrypt khớp plaintext gốc', () {
      const counter = 42;
      final plain = utf8.encode('{"cmd":"open"}');
      final frame = crypto.encryptCommand(
        sessionKey: sessionKey,
        counter: counter,
        plaintext: plain,
      );
      final decrypted = crypto.decryptFrame(
        sessionKey: sessionKey,
        frame: frame,
      );
      expect(utf8.decode(decrypted), '{"cmd":"open"}');
    });

    test('counter big-endian: 0x0102030405060708 → đúng layout', () {
      const counter = 0x0102030405060708;
      final frame = crypto.encryptCommand(
        sessionKey: sessionKey,
        counter: counter,
        plaintext: utf8.encode('{"cmd":"stop"}'),
      );
      expect(frame.sublist(0, 8),
          Uint8List.fromList([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08]));
    });

    test('tag mặc định 8 bytes (KHÁC pairing 16B)', () {
      final plain = utf8.encode('{"cmd":"close"}');
      final frame = crypto.encryptCommand(
        sessionKey: sessionKey,
        counter: 1,
        plaintext: plain,
      );
      final ctWithTag = frame.sublist(8);
      expect(ctWithTag.length, plain.length + 8);
    });

    test('IV derive deterministic — cùng counter+plaintext → cùng frame', () {
      // Spec v2: KHÔNG random IV, IV = counter || 0x00*4 → encrypt cùng
      // counter+plaintext luôn ra cùng output (chính xác cho test golden).
      final plain = utf8.encode('{"cmd":"open"}');
      final a = crypto.encryptCommand(
          sessionKey: sessionKey, counter: 1, plaintext: plain);
      final b = crypto.encryptCommand(
          sessionKey: sessionKey, counter: 1, plaintext: plain);
      expect(a, b);
    });

    test('counter khác → IV khác → ciphertext khác', () {
      final plain = utf8.encode('{"cmd":"open"}');
      final a = crypto.encryptCommand(
          sessionKey: sessionKey, counter: 1, plaintext: plain);
      final b = crypto.encryptCommand(
          sessionKey: sessionKey, counter: 2, plaintext: plain);
      expect(a, isNot(b));
      // Counter bytes khác, ciphertext khác (do IV thay đổi theo counter)
      expect(a.sublist(0, 8), isNot(b.sublist(0, 8)));
      expect(a.sublist(8), isNot(b.sublist(8)));
    });

    test('AAD = counter bytes → decrypt với counter sai phải fail', () {
      final plain = utf8.encode('{"cmd":"open"}');
      final encrypted = crypto.encryptCommand(
        sessionKey: sessionKey,
        counter: 100,
        plaintext: plain,
      );
      // Sửa byte đầu của counter trong frame → IV + AAD đều mismatch
      final tampered = Uint8List.fromList(encrypted);
      tampered[0] = tampered[0] ^ 0x01;
      expect(
        () => crypto.decryptFrame(sessionKey: sessionKey, frame: tampered),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('BleControlCrypto — input validation', () {
    test('sessionKey ≠ 32 bytes → ArgumentError', () {
      expect(
        () => crypto.encryptCommand(
            sessionKey: Uint8List(16),
            counter: 1,
            plaintext: utf8.encode('{}')),
        throwsArgumentError,
      );
    });

    test('counter < 0 → ArgumentError', () {
      expect(
        () => crypto.encryptCommand(
            sessionKey: sessionKey,
            counter: -1,
            plaintext: utf8.encode('{}')),
        throwsArgumentError,
      );
    });

    test('frame quá ngắn để decrypt → ArgumentError', () {
      expect(
        () => crypto.decryptFrame(sessionKey: sessionKey, frame: Uint8List(10)),
        throwsArgumentError,
      );
    });
  });

  group('BleControlCrypto — decodeNotify (§5.3)', () {
    test('0x00 → ok', () {
      expect(crypto.decodeNotify(0x00), BleControlResult.ok);
    });

    test('0x01 → decryptFailed (trigger re-pair)', () {
      expect(crypto.decodeNotify(0x01), BleControlResult.decryptFailed);
    });

    test('0x02 → replayRejected (trigger re-pair)', () {
      expect(crypto.decodeNotify(0x02), BleControlResult.replayRejected);
    });

    test('0x03 → unknownCommand', () {
      expect(crypto.decodeNotify(0x03), BleControlResult.unknownCommand);
    });

    test('0x04 → motorBusy', () {
      expect(crypto.decodeNotify(0x04), BleControlResult.motorBusy);
    });

    test('byte ngoài range → unknownStatus', () {
      expect(crypto.decodeNotify(0xFF), BleControlResult.unknownStatus);
      expect(crypto.decodeNotify(0x99), BleControlResult.unknownStatus);
    });
  });

  group('Cmd variants (§5.2 plaintext)', () {
    // Note: v1 spec firmware chỉ support open/close/stop. pct là TODO theo
    // spec v2 — vẫn test round-trip để pct path sẵn sàng khi firmware ship.
    const variants = [
      '{"cmd":"open"}',
      '{"cmd":"close"}',
      '{"cmd":"stop"}',
      '{"cmd":"pct","v":0}',
      '{"cmd":"pct","v":50}',
      '{"cmd":"pct","v":100}',
    ];
    for (final json in variants) {
      test('round-trip "$json"', () {
        final plain = utf8.encode(json);
        final frame = crypto.encryptCommand(
          sessionKey: sessionKey,
          counter: 1,
          plaintext: plain,
        );
        final out = crypto.decryptFrame(sessionKey: sessionKey, frame: frame);
        expect(utf8.decode(out), json);
      });
    }
  });
}
