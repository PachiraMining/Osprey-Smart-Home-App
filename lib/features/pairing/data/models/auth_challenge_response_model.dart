import 'package:equatable/equatable.dart';

/// Response của `POST /api/smarthome/pairing/auth-challenge`
/// (handoff checklist §2.1 — keys camelCase, hex strings).
class AuthChallengeResponseModel extends Equatable {
  /// 32 bytes hex — WRITE xuống device cùng nonce_app.
  final String hmacExpectedHex;

  /// 32 bytes hex — [0:16] AES key, [16:28] IV cho AES-CCM.
  final String sessionKeyHex;

  final String tbProvisionKey;
  final String tbProvisionSecret;
  final String deviceProfileId;

  const AuthChallengeResponseModel({
    required this.hmacExpectedHex,
    required this.sessionKeyHex,
    required this.tbProvisionKey,
    required this.tbProvisionSecret,
    required this.deviceProfileId,
  });

  factory AuthChallengeResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthChallengeResponseModel(
      hmacExpectedHex: _hex(json['hmacExpected'] ?? json['hmac_expected']),
      sessionKeyHex: _hex(json['sessionKey'] ?? json['session_key']),
      tbProvisionKey:
          (json['tbProvisionKey'] ?? json['tb_provision_key'] ?? '') as String,
      tbProvisionSecret:
          (json['tbProvisionSecret'] ?? json['tb_provision_secret'] ?? '')
              as String,
      deviceProfileId: _unwrapId(
          json['deviceProfileId'] ?? json['device_profile_id']),
    );
  }

  static String _hex(dynamic raw) {
    final s = (raw ?? '') as String;
    return s.startsWith('0x') ? s.substring(2) : s;
  }

  static String _unwrapId(dynamic raw) {
    if (raw == null) return '';
    if (raw is String) return raw;
    if (raw is Map) return (raw['id'] ?? '') as String;
    return raw.toString();
  }

  @override
  List<Object?> get props => [
        hmacExpectedHex,
        sessionKeyHex,
        tbProvisionKey,
        tbProvisionSecret,
        deviceProfileId,
      ];
}
