import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/ccm.dart';
import 'package:pointycastle/api.dart' as pc;

import '../../pairing_constants.dart';

/// Crypto primitives cho Osprey BLE pairing protocol (spec §5).
///
/// - HMAC-SHA256: verify device là hàng thật (mutual auth qua PSK)
/// - HKDF-SHA256: derive session key (chỉ dùng cho unit test đối chiếu —
///   production app nhận sessionKey từ backend, không bao giờ thấy PSK)
/// - AES-128-CCM: encrypt PAIRING_DATA (WiFi credentials) trước khi WRITE
///
/// Lưu ý: package:cryptography KHÔNG có AES-CCM nên phần CCM dùng
/// pointycastle. Đã verify byte-by-byte với tools/sim_pairing.py
/// (golden oracle từ firmware vendor) trong pairing_crypto_test.dart.
class PairingCrypto {
  static final Random _secureRandom = Random.secure();

  /// Nonce ngẫu nhiên 16 bytes, MỚI cho mỗi pairing attempt (chống replay).
  Uint8List generateNonce() {
    final nonce = Uint8List(PairingConstants.nonceLength);
    for (var i = 0; i < nonce.length; i++) {
      nonce[i] = _secureRandom.nextInt(256);
    }
    return nonce;
  }

  /// `HMAC-SHA256(key = PSK, data = "auth-challenge-v1" || nonce_app)`.
  ///
  /// Production: backend tính giá trị này (app không có PSK). Hàm này dùng
  /// để unit test khớp reference values trong handoff checklist §3.
  Future<Uint8List> computeAuthHmac({
    required List<int> psk,
    required List<int> nonceApp,
  }) async {
    final hmac = Hmac.sha256();
    final mac = await hmac.calculateMac(
      [...PairingConstants.hmacDomainSeparator.codeUnits, ...nonceApp],
      secretKey: SecretKey(psk),
    );
    return Uint8List.fromList(mac.bytes);
  }

  /// `HKDF-SHA256(salt = nonce_app, ikm = PSK, info = "osprey-pairing-v1")`
  /// → 32 bytes (spec §5.4 single-sided derivation).
  Future<Uint8List> deriveSessionKey({
    required List<int> psk,
    required List<int> nonceApp,
  }) async {
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final key = await hkdf.deriveKey(
      secretKey: SecretKey(psk),
      nonce: nonceApp,
      info: PairingConstants.hkdfInfo.codeUnits,
    );
    return Uint8List.fromList(await key.extractBytes());
  }

  /// AUTH_CHALLENGE payload 48 bytes: `[nonce_app:16][hmac_expected:32]`.
  Uint8List buildAuthChallengePayload({
    required List<int> nonceApp,
    required List<int> hmacExpected,
  }) {
    if (nonceApp.length != PairingConstants.nonceLength) {
      throw ArgumentError('nonce_app must be exactly 16 bytes');
    }
    if (hmacExpected.length != 32) {
      throw ArgumentError('hmac_expected must be exactly 32 bytes');
    }
    return Uint8List.fromList([...nonceApp, ...hmacExpected]);
  }

  /// AES-128-CCM encrypt PAIRING_DATA (spec §5.5):
  /// - key = sessionKey[0:16]
  /// - iv  = sessionKey[16:28] (12 bytes)
  /// - tag = 16 bytes, append vào cuối ciphertext
  /// - AAD = none
  Uint8List encryptPairingData({
    required List<int> sessionKey,
    required List<int> plaintext,
  }) {
    if (sessionKey.length != 32) {
      throw ArgumentError('session_key must be exactly 32 bytes');
    }
    final cipher = _buildCcm(
      sessionKey: sessionKey,
      forEncryption: true,
      messageLength: plaintext.length,
    );
    return cipher.process(Uint8List.fromList(plaintext));
  }

  /// Decrypt — dùng cho unit test roundtrip; throw nếu MAC verify fail.
  Uint8List decryptPairingData({
    required List<int> sessionKey,
    required List<int> ciphertextWithTag,
  }) {
    final cipher = _buildCcm(
      sessionKey: sessionKey,
      forEncryption: false,
      messageLength: ciphertextWithTag.length,
    );
    return cipher.process(Uint8List.fromList(ciphertextWithTag));
  }

  CCMBlockCipher _buildCcm({
    required List<int> sessionKey,
    required bool forEncryption,
    required int messageLength,
  }) {
    final key = Uint8List.fromList(sessionKey.sublist(0, 16));
    final iv = Uint8List.fromList(sessionKey.sublist(16, 28));
    final cipher = CCMBlockCipher(AESEngine());
    cipher.init(
      forEncryption,
      pc.AEADParameters(
        pc.KeyParameter(key),
        128, // tag 16 bytes
        iv,
        Uint8List(0), // AAD = none
      ),
    );
    return cipher;
  }
}
