import 'dart:typed_data';

/// Hex encode/decode cho crypto material (nonce, HMAC, session key).
class HexUtils {
  HexUtils._();

  static String encode(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  static Uint8List decode(String hex) {
    final cleaned = hex.startsWith('0x') ? hex.substring(2) : hex;
    if (cleaned.length.isOdd) {
      throw FormatException('Hex string phải có độ dài chẵn: $hex');
    }
    final result = Uint8List(cleaned.length ~/ 2);
    for (var i = 0; i < result.length; i++) {
      final byte = int.tryParse(cleaned.substring(i * 2, i * 2 + 2), radix: 16);
      if (byte == null) {
        throw FormatException('Hex string không hợp lệ: $hex');
      }
      result[i] = byte;
    }
    return result;
  }
}
