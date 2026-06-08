import 'package:equatable/equatable.dart';

/// Pairing token từ `POST /api/smarthome/pairing/token` và
/// `GET /api/smarthome/pairing/token/{token}` (8 ký tự, TTL 15 phút).
class PairingTokenModel extends Equatable {
  final String token;

  /// PENDING | PAIRED | EXPIRED | CANCELLED
  final String status;

  /// TB device id — chỉ có khi status = PAIRED.
  final String? deviceId;

  final int? expiresAt;

  const PairingTokenModel({
    required this.token,
    required this.status,
    this.deviceId,
    this.expiresAt,
  });

  bool get isPaired => status == 'PAIRED';
  bool get isExpired => status == 'EXPIRED' || status == 'CANCELLED';

  factory PairingTokenModel.fromJson(Map<String, dynamic> json) {
    return PairingTokenModel(
      token: (json['token'] ?? '') as String,
      status: (json['status'] ?? 'PENDING') as String,
      deviceId: _unwrapId(json['deviceId'] ?? json['device_id']),
      expiresAt: (json['expiresAt'] ?? json['expires_at']) as int?,
    );
  }

  static String? _unwrapId(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return raw.isEmpty ? null : raw;
    if (raw is Map) return raw['id'] as String?;
    return raw.toString();
  }

  @override
  List<Object?> get props => [token, status, deviceId, expiresAt];
}
