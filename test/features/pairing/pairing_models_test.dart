import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/pairing/data/models/auth_challenge_response_model.dart';
import 'package:smart_curtain_app/features/pairing/data/models/osprey_product_model.dart';
import 'package:smart_curtain_app/features/pairing/data/models/pairing_token_model.dart';

void main() {
  group('OspreyProductModel', () {
    // Sample response thật từ handoff checklist §2.1
    final backendJson = {
      'id': {
        'entityType': 'OSPREY_PRODUCT',
        'id': '6f1660b0-5b43-11f1-bf1c-5d39e2c8084e',
      },
      'productCode': 'OSPREY_CURTAIN_V1',
      'productType': 1,
      'productIdHash': 'oM4Q', // base64 của 0xA0,0xCE,0x10
      'displayName': 'Smart Curtain Track V1 (updated)',
      'iconUrl': 'https://cdn.osprey.test/icons/curtain.png',
      'category': 'CURTAIN',
      'deviceProfileId': {
        'entityType': 'DEVICE_PROFILE',
        'id': '205412d0-187f-11f1-9504-4707df8f1447',
      },
      'version': 2,
    };

    test('fromJson: unwrap id wrappers + base64 hash → hex', () {
      final model = OspreyProductModel.fromJson(backendJson);
      expect(model.id, '6f1660b0-5b43-11f1-bf1c-5d39e2c8084e');
      expect(model.productCode, 'OSPREY_CURTAIN_V1');
      expect(model.productType, 1);
      expect(model.productIdHashHex, 'a0ce10'); // base64 oM4Q decoded
      expect(model.deviceProfileId, '205412d0-187f-11f1-9504-4707df8f1447');
    });

    test('fromJson: chấp nhận hash dạng hex sẵn (từ cache)', () {
      final model = OspreyProductModel.fromJson({
        ...backendJson,
        'productIdHash': 'A0CE10',
      });
      expect(model.productIdHashHex, 'a0ce10');
    });

    test('toJson → fromJson roundtrip (cache)', () {
      final model = OspreyProductModel.fromJson(backendJson);
      final restored = OspreyProductModel.fromJson(model.toJson());
      expect(restored, model);
    });

    test('fromJson: chấp nhận snake_case (spec §6.1)', () {
      final model = OspreyProductModel.fromJson({
        'id': 'uuid-1',
        'product_code': 'OSPREY_CURTAIN_V1',
        'product_type': 1,
        'product_id_hash': 'a0ce10',
        'display_name': 'Smart Curtain Track',
        'icon_url': 'https://cdn/x.png',
        'category': 'CURTAIN',
        'device_profile_id': 'dp-1',
      });
      expect(model.productCode, 'OSPREY_CURTAIN_V1');
      expect(model.productIdHashHex, 'a0ce10');
      expect(model.deviceProfileId, 'dp-1');
    });
  });

  group('AuthChallengeResponseModel', () {
    test('fromJson camelCase (handoff checklist §2.1)', () {
      final model = AuthChallengeResponseModel.fromJson({
        'hmacExpected': '3dde8f26',
        'sessionKey': '08df2a1f',
        'tbProvisionKey': 'OSPREY_CURTAIN_V1',
        'tbProvisionSecret': 'osprey_curtain_test_secret_v1_xxxx',
        'deviceProfileId': '205412d0-187f-11f1-9504-4707df8f1447',
      });
      expect(model.hmacExpectedHex, '3dde8f26');
      expect(model.sessionKeyHex, '08df2a1f');
      expect(model.tbProvisionKey, 'OSPREY_CURTAIN_V1');
      expect(model.deviceProfileId, '205412d0-187f-11f1-9504-4707df8f1447');
    });

    test('fromJson: strip 0x prefix + snake_case fallback', () {
      final model = AuthChallengeResponseModel.fromJson({
        'hmac_expected': '0x9F8E7D',
        'session_key': '0x1A2B3C',
      });
      expect(model.hmacExpectedHex, '9F8E7D');
      expect(model.sessionKeyHex, '1A2B3C');
    });
  });

  group('PairingTokenModel', () {
    test('PENDING → chưa paired', () {
      final model = PairingTokenModel.fromJson({
        'token': 'AYHIXY6X',
        'status': 'PENDING',
        'expiresAt': 1779999999000,
      });
      expect(model.isPaired, false);
      expect(model.isExpired, false);
      expect(model.deviceId, isNull);
    });

    test('PAIRED → có deviceId', () {
      final model = PairingTokenModel.fromJson({
        'token': 'AYHIXY6X',
        'status': 'PAIRED',
        'deviceId': {'entityType': 'DEVICE', 'id': 'dev-123'},
      });
      expect(model.isPaired, true);
      expect(model.deviceId, 'dev-123');
    });

    test('EXPIRED / CANCELLED → isExpired', () {
      expect(
        PairingTokenModel.fromJson({'token': 'T', 'status': 'EXPIRED'})
            .isExpired,
        true,
      );
      expect(
        PairingTokenModel.fromJson({'token': 'T', 'status': 'CANCELLED'})
            .isExpired,
        true,
      );
    });
  });
}
