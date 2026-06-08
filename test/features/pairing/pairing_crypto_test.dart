import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/pairing/data/crypto/hex_utils.dart';
import 'package:smart_curtain_app/features/pairing/data/crypto/pairing_crypto.dart';

/// Đối chiếu byte-by-byte với golden oracle của firmware vendor
/// (tools/sim_pairing.py) — chạy ngày 2026-06-04, PSK = 0xAA×32,
/// nonce_app = 0x00×16. Reference values từ ble-handoff-checklist.md §3.
void main() {
  final crypto = PairingCrypto();

  // Test vectors (handoff checklist §3 + sim_pairing.py output)
  final psk = List<int>.filled(32, 0xAA);
  final nonceApp = List<int>.filled(16, 0x00);
  const expectedHmacHex =
      '3dde8f263a33d1c9b077e2caa9851d2e6722e4db5dabfbd835dc33a03b048513';
  const expectedSessionKeyHex =
      '08df2a1f3972b6157fbbc66434f520d5ba24d64657fe66d0fc2f784d097a9bfa';

  group('HexUtils', () {
    test('encode/decode roundtrip', () {
      expect(HexUtils.encode([0xA0, 0xCE, 0x10]), 'a0ce10');
      expect(HexUtils.decode('a0ce10'), [0xA0, 0xCE, 0x10]);
      expect(HexUtils.decode('0xA0CE10'), [0xA0, 0xCE, 0x10]);
    });

    test('decode rejects invalid input', () {
      expect(() => HexUtils.decode('abc'), throwsFormatException);
      expect(() => HexUtils.decode('zz'), throwsFormatException);
    });
  });

  group('PairingCrypto — reference values (handoff §3)', () {
    test('HMAC-SHA256("auth-challenge-v1" || nonce_app) khớp reference', () async {
      final mac = await crypto.computeAuthHmac(psk: psk, nonceApp: nonceApp);
      expect(HexUtils.encode(mac), expectedHmacHex);
    });

    test('HKDF session key khớp reference', () async {
      final key = await crypto.deriveSessionKey(psk: psk, nonceApp: nonceApp);
      expect(HexUtils.encode(key), expectedSessionKeyHex);
    });

    test('AUTH_CHALLENGE payload = 48 bytes [nonce][hmac]', () async {
      final mac = await crypto.computeAuthHmac(psk: psk, nonceApp: nonceApp);
      final payload =
          crypto.buildAuthChallengePayload(nonceApp: nonceApp, hmacExpected: mac);
      expect(payload.length, 48);
      expect(
        HexUtils.encode(payload),
        '00000000000000000000000000000000$expectedHmacHex',
      );
    });

    test('AUTH_CHALLENGE payload validate độ dài input', () {
      expect(
        () => crypto.buildAuthChallengePayload(
            nonceApp: [1, 2, 3], hmacExpected: List.filled(32, 0)),
        throwsArgumentError,
      );
      expect(
        () => crypto.buildAuthChallengePayload(
            nonceApp: List.filled(16, 0), hmacExpected: [1, 2]),
        throwsArgumentError,
      );
    });
  });

  group('PairingCrypto — AES-128-CCM (golden oracle sim_pairing.py)', () {
    // PAIRING_JSON y hệt sim_pairing.py (cùng thứ tự field, compact JSON)
    const pairingJson = {
      'token': 'TEST1234',
      'ssid': 'Osprey Technology 2 2.4G',
      'password': 'dracaena123',
      'mqtt_url': 'tcp://performentmarketing.ddnsgeek.com:1883',
      'http_api_base_url': 'http://performentmarketing.ddnsgeek.com:8080',
      'tb_provision_key': 'OSPREY_CURTAIN_V1',
      'tb_provision_secret': 'osprey_curtain_test_secret_v1_xxxx',
    };

    // Output của `python3 tools/sim_pairing.py` (cipher+tag, 317 bytes)
    const goldenCiphertextHex =
        '1e503a6e49eea689b9a4a6a62e63fd0c054425d289f7c28ba7d380e3cf4e6c20'
        '051ed6e40b4452eb1ea7cbb1116f93dddacf6070d87d3c061b15ed417a14c7ee'
        '1ccd2262b543a722ca1890e119929636137109039ac4d8b68ffff210bbc23ff4'
        '4afd8585c8cac957269091590e090552a17fee98ede4be1f9a0c4972834ee000'
        '13e763db5b541d9aab11845465b900d245393303c5d3ced4331157cddb58e1ef'
        '9127320f1f8a5eb0b0ec841f4f034c9da51ce47f97f187482a98451bf37507e2'
        '93391a94d9d2f05cbac2a6047c9e7d309104d79fbf80bcbac58372d08a95fb4e'
        '08f3a1fc94f6d72c028196540baee40095391c4bf34cc458919b1c14b8c0771d'
        '7a2570047e56157f8397cfa55c00de8f514ad9a1ff28d19939b8a36de5b03416'
        '7f99471824ce53456a256c4137ab1d52a449c302f22186b6893d4c4ba6';

    test('ciphertext khớp byte-by-byte với golden oracle', () {
      final sessionKey = HexUtils.decode(expectedSessionKeyHex);
      final plaintext = utf8.encode(jsonEncode(pairingJson));
      expect(plaintext.length, 301); // sanity: cùng plaintext với python

      final ciphertext = crypto.encryptPairingData(
        sessionKey: sessionKey,
        plaintext: plaintext,
      );
      expect(ciphertext.length, 317); // 301 + 16 tag
      expect(HexUtils.encode(ciphertext), goldenCiphertextHex);
    });

    test('encrypt → decrypt roundtrip', () {
      final sessionKey = HexUtils.decode(expectedSessionKeyHex);
      final plaintext = utf8.encode('{"hello":"osprey"}');
      final ciphertext = crypto.encryptPairingData(
        sessionKey: sessionKey,
        plaintext: plaintext,
      );
      final decrypted = crypto.decryptPairingData(
        sessionKey: sessionKey,
        ciphertextWithTag: ciphertext,
      );
      expect(decrypted, plaintext);
    });

    test('decrypt fail khi ciphertext bị sửa (MAC check)', () {
      final sessionKey = HexUtils.decode(expectedSessionKeyHex);
      final ciphertext = crypto.encryptPairingData(
        sessionKey: sessionKey,
        plaintext: utf8.encode('{"a":1}'),
      );
      ciphertext[0] ^= 0xFF; // corrupt
      expect(
        () => crypto.decryptPairingData(
          sessionKey: sessionKey,
          ciphertextWithTag: ciphertext,
        ),
        throwsA(anything),
      );
    });

    test('session key sai độ dài bị reject', () {
      expect(
        () => crypto.encryptPairingData(
            sessionKey: [1, 2, 3], plaintext: [0]),
        throwsArgumentError,
      );
    });
  });

  group('PairingCrypto — nonce', () {
    test('nonce 16 bytes, mỗi lần khác nhau', () {
      final a = crypto.generateNonce();
      final b = crypto.generateNonce();
      expect(a.length, 16);
      expect(b.length, 16);
      expect(a, isNot(equals(b)));
    });
  });
}
