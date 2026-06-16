import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/control/data/crypto/ble_control_crypto.dart';
import 'package:smart_curtain_app/features/control/domain/entities/ble_control_result.dart';
import 'package:smart_curtain_app/features/pairing/data/crypto/hex_utils.dart';

void main() {
  final crypto = BleControlCrypto();

  // Fixed session key + IV cho golden-vector style assertions (lặp lại được).
  // Session key này khớp pairing-crypto-test reference (PSK=0xAA, nonce=0x00).
  final sessionKey = Uint8List.fromList(HexUtils.decode(
      '08df2a1f3972b6157fbbc66434f520d5ba24d64657fe66d0fc2f784d097a9bfa'));
  final fixedIv = Uint8List.fromList(List<int>.filled(13, 0x33));

  group('BleControlCrypto — wire format §5.2', () {
    test('encrypted frame layout = [counter:8][iv:13][ct][tag:8]', () {
      const counter = 1;
      final plain = utf8.encode('{"cmd":"open"}');
      final frame = crypto.encryptCommandWithIv(
        sessionKey: sessionKey,
        counter: counter,
        iv: fixedIv,
        plaintext: plain,
      );
      // 8 counter + 13 iv + plaintext + 8 tag
      expect(frame.length, 8 + 13 + plain.length + 8);

      // Counter ở 8 byte đầu, big-endian
      expect(frame.sublist(0, 8), Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 1]));
      // IV ở 13 byte tiếp theo
      expect(frame.sublist(8, 8 + 13), fixedIv);
    });

    test('round-trip decrypt khớp plaintext gốc', () {
      const counter = 42;
      final plain = utf8.encode('{"cmd":"pct","v":67}');
      final frame = crypto.encryptCommandWithIv(
        sessionKey: sessionKey,
        counter: counter,
        iv: fixedIv,
        plaintext: plain,
      );
      final decrypted = crypto.decryptFrame(
        sessionKey: sessionKey,
        frame: frame,
      );
      expect(utf8.decode(decrypted), '{"cmd":"pct","v":67}');
    });

    test('counter big-endian: 0x0102030405060708 → đúng layout', () {
      const counter = 0x0102030405060708;
      final frame = crypto.encryptCommandWithIv(
        sessionKey: sessionKey,
        counter: counter,
        iv: fixedIv,
        plaintext: utf8.encode('{"cmd":"stop"}'),
      );
      expect(frame.sublist(0, 8),
          Uint8List.fromList([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08]));
    });

    test('tag mặc định 8 bytes (KHÔNG phải 16 như pairing)', () {
      final plain = utf8.encode('{"cmd":"close"}');
      final frame = crypto.encryptCommandWithIv(
        sessionKey: sessionKey,
        counter: 1,
        iv: fixedIv,
        plaintext: plain,
      );
      final ctWithTag = frame.sublist(8 + 13);
      // plaintext length = 15, ciphertext same length (CCM = CTR encrypt) + 8B tag
      expect(ctWithTag.length, plain.length + 8);
    });

    test('AAD = counter bytes → decrypt với counter sai phải fail', () {
      final plain = utf8.encode('{"cmd":"open"}');
      final encrypted = crypto.encryptCommandWithIv(
        sessionKey: sessionKey,
        counter: 100,
        iv: fixedIv,
        plaintext: plain,
      );
      // Sửa byte đầu của counter trong frame → MAC verify fail
      final tampered = Uint8List.fromList(encrypted);
      tampered[0] = tampered[0] ^ 0x01;
      expect(
        () => crypto.decryptFrame(sessionKey: sessionKey, frame: tampered),
        throwsA(isA<StateError>()),
      );
    });

    test('IV ngẫu nhiên: 2 lần encrypt cùng plaintext → frame KHÁC', () {
      final plain = utf8.encode('{"cmd":"open"}');
      final a = crypto.encryptCommand(
          sessionKey: sessionKey, counter: 1, plaintext: plain);
      final b = crypto.encryptCommand(
          sessionKey: sessionKey, counter: 1, plaintext: plain);
      // IV random → ciphertext + tag khác nhau (counter giống nhau, plaintext giống nhau)
      expect(a.sublist(8, 8 + 13), isNot(b.sublist(8, 8 + 13)));
      expect(a, isNot(b));
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

    test('IV ≠ 13 bytes → ArgumentError', () {
      expect(
        () => crypto.encryptCommandWithIv(
          sessionKey: sessionKey,
          counter: 1,
          iv: Uint8List(12),
          plaintext: utf8.encode('{}'),
        ),
        throwsArgumentError,
      );
    });

    test('frame quá ngắn để decrypt → ArgumentError', () {
      expect(
        () => crypto.decryptFrame(sessionKey: sessionKey, frame: Uint8List(20)),
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
        final frame = crypto.encryptCommandWithIv(
          sessionKey: sessionKey,
          counter: 1,
          iv: fixedIv,
          plaintext: plain,
        );
        final out = crypto.decryptFrame(sessionKey: sessionKey, frame: frame);
        expect(utf8.decode(out), json);
      });
    }
  });
}
