import 'dart:typed_data';

import 'package:pointycastle/api.dart' as pc;
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/ccm.dart';

import '../../domain/entities/ble_control_result.dart';

/// Crypto cho BLE Control wire format (spec v2 §5.2 — commit ab34570d):
///
/// ```
/// wire = [counter:8B big-EN][ciphertext:var][tag:8B]
/// ```
///
/// IV được DERIVE từ counter (không random, không nằm trong wire):
/// ```
/// iv  = counter (8B big-EN) || 0x00 0x00 0x00 0x00     (12 bytes)
/// key = sessionKey[0..16]                              (16 bytes)
/// aad = counter (8B big-EN)                            (8 bytes)
/// tag = 8 bytes (KHÁC pairing crypto tag 16B)
/// ```
///
/// Counter monotonic chip-side → mỗi command 1 IV duy nhất, không nonce
/// reuse. Wire ngắn hơn spec v1 (bỏ 13B random IV).
class BleControlCrypto {
  /// Build frame mã hoá để WRITE vào BLE_CONTROL_CMD.
  ///
  /// [plaintextJson] ví dụ `{"cmd":"open"}` (firmware §6.2 parse bằng strstr).
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
    return _frame(
      sessionKey: sessionKey,
      counter: counter,
      plaintext: plaintext,
    );
  }

  /// Decrypt frame (dùng cho test roundtrip + mock BLE peer).
  /// Throw nếu MAC verify fail.
  Uint8List decryptFrame({
    required Uint8List sessionKey,
    required Uint8List frame,
  }) {
    // Min: counter(8) + tag(8) — ciphertext có thể rỗng (lệnh trống vô nghĩa
    // nhưng vẫn parse được)
    if (frame.length < 8 + 8) {
      throw ArgumentError(
          'frame too short: need ≥16B (counter+tag), got ${frame.length}');
    }
    final counterBytes = frame.sublist(0, 8);
    final ctWithTag = frame.sublist(8);

    final iv = _deriveIv(counterBytes);
    final cipher = _buildCcm(
      sessionKey: sessionKey,
      iv: iv,
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

  Uint8List _frame({
    required Uint8List sessionKey,
    required int counter,
    required List<int> plaintext,
  }) {
    final counterBytes = _u64BigEndian(counter);
    final iv = _deriveIv(counterBytes);
    final cipher = _buildCcm(
      sessionKey: sessionKey,
      iv: iv,
      aad: counterBytes,
      forEncryption: true,
    );
    final ctWithTag = cipher.process(Uint8List.fromList(plaintext));
    return Uint8List.fromList([...counterBytes, ...ctWithTag]);
  }

  /// IV = counter (8B big-EN) || 0x00 0x00 0x00 0x00 = 12 bytes total.
  static Uint8List _deriveIv(List<int> counterBytes) {
    assert(counterBytes.length == 8, 'counter must be 8 bytes big-EN');
    return Uint8List.fromList([...counterBytes, 0x00, 0x00, 0x00, 0x00]);
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
        64, // tag size in BITS = 8 bytes
        iv,
        aad,
      ),
    );
    return cipher;
  }
}
