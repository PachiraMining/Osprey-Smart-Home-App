import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/api.dart' as pc;
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/ccm.dart';

import '../../domain/entities/ble_control_result.dart';

/// Crypto cho BLE Control wire format (spec §5.2):
///
/// ```
/// [counter:8B big-EN][IV:13B random][ciphertext:var][tag:8B]
/// ```
///
/// - key   = sessionKey[0..16]   (16 bytes)
/// - nonce = IV                  (13 bytes random)
/// - aad   = counter bytes       (8 bytes big-endian — KHÔNG encrypt, chỉ MAC)
/// - tag   = **8 bytes** (KHÁC pairing — pairing tag 16B; chip parse mặc định 8B)
///
/// Phần ciphertext+tag do AES-CCM-128 trả về liền nhau (pointycastle convention).
class BleControlCrypto {
  static final Random _secureRandom = Random.secure();

  /// Build frame mã hoá để WRITE vào BLE_CONTROL_CMD.
  ///
  /// [plaintextJson] ví dụ `{"cmd":"open"}` / `{"cmd":"pct","v":67}` —
  /// chip parse `strstr` (xem §6.2) nên format JSON tự do, miễn có key đúng.
  Uint8List encryptCommand({
    required Uint8List sessionKey,
    required int counter,
    required List<int> plaintext,
  }) {
    if (sessionKey.length != 32) {
      throw ArgumentError('sessionKey must be exactly 32 bytes');
    }
    if (counter < 0) {
      throw ArgumentError('counter must be non-negative');
    }
    final iv = _randomIv();
    return _frame(
      sessionKey: sessionKey,
      counter: counter,
      iv: iv,
      plaintext: plaintext,
    );
  }

  /// Build với IV cố định — chỉ dùng cho test golden vectors.
  Uint8List encryptCommandWithIv({
    required Uint8List sessionKey,
    required int counter,
    required Uint8List iv,
    required List<int> plaintext,
  }) {
    if (iv.length != 13) {
      throw ArgumentError('IV must be exactly 13 bytes (CCM L=2)');
    }
    return _frame(
      sessionKey: sessionKey,
      counter: counter,
      iv: iv,
      plaintext: plaintext,
    );
  }

  /// Decrypt frame (dùng cho test roundtrip + mock BLE peer).
  /// Throw nếu MAC verify fail.
  Uint8List decryptFrame({
    required Uint8List sessionKey,
    required Uint8List frame,
  }) {
    if (frame.length < 8 + 13 + 8) {
      throw ArgumentError(
          'frame too short: need ≥29B (counter+iv+tag), got ${frame.length}');
    }
    final counterBytes = frame.sublist(0, 8);
    final iv = frame.sublist(8, 8 + 13);
    final ctWithTag = frame.sublist(8 + 13);

    final cipher = _buildCcm(
      sessionKey: sessionKey,
      iv: Uint8List.fromList(iv),
      aad: Uint8List.fromList(counterBytes),
      forEncryption: false,
    );
    return cipher.process(Uint8List.fromList(ctWithTag));
  }

  /// Map notify byte (§5.3) sang result enum.
  BleControlResult decodeNotify(int notifyByte) {
    return switch (notifyByte) {
      0x00 => BleControlResult.ok,
      0x01 => BleControlResult.decryptFailed,
      0x02 => BleControlResult.replayRejected,
      0x03 => BleControlResult.unknownCommand,
      0x04 => BleControlResult.motorBusy,
      _ => BleControlResult.unknownStatus,
    };
  }

  Uint8List _randomIv() {
    final iv = Uint8List(13);
    for (var i = 0; i < iv.length; i++) {
      iv[i] = _secureRandom.nextInt(256);
    }
    return iv;
  }

  Uint8List _frame({
    required Uint8List sessionKey,
    required int counter,
    required Uint8List iv,
    required List<int> plaintext,
  }) {
    final counterBytes = _u64BigEndian(counter);
    final cipher = _buildCcm(
      sessionKey: sessionKey,
      iv: iv,
      aad: counterBytes,
      forEncryption: true,
    );
    final ctWithTag = cipher.process(Uint8List.fromList(plaintext));
    return Uint8List.fromList([...counterBytes, ...iv, ...ctWithTag]);
  }

  static Uint8List _u64BigEndian(int value) {
    final out = Uint8List(8);
    var v = value;
    for (var i = 7; i >= 0; i--) {
      out[i] = v & 0xFF;
      v = v >> 8;
    }
    return out;
  }

  static CCMBlockCipher _buildCcm({
    required Uint8List sessionKey,
    required Uint8List iv,
    required Uint8List aad,
    required bool forEncryption,
  }) {
    final key = Uint8List.fromList(sessionKey.sublist(0, 16));
    final cipher = CCMBlockCipher(AESEngine());
    cipher.init(
      forEncryption,
      pc.AEADParameters(
        pc.KeyParameter(key),
        64, // tag size in BITS = 8 bytes (spec §5.2 — khác pairing 128 bits)
        iv,
        aad,
      ),
    );
    return cipher;
  }
}
