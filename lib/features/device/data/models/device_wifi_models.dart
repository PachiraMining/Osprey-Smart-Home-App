// Models cho tính năng Multi-WiFi Management (Smart Curtain Track).
//
// Tương ứng 5 endpoint backend dưới /api/smarthome/devices/{deviceId}/...
// Xem spec "Multi-WiFi Management" 2026-06-15.

import 'package:equatable/equatable.dart';

/// Trạng thái mạng hiện tại của chip — GET /network-info.
class DeviceNetworkInfo extends Equatable {
  /// SSID chip đang kết nối; null nếu chip chưa publish (mới pair / offline).
  final String? currentSsid;

  /// "device_attribute" = telemetry thật, "db_active" = từ DB, "unknown".
  final String? currentSsidSource;

  /// RSSI dBm (số âm). null nếu firmware không publish → ẩn thanh sóng.
  final int? rssiDbm;

  /// ms epoch — chip publish currentSsid lần cuối.
  final int? lastReportedAt;

  /// id của saved wifi khớp currentSsid; null nếu không khớp entry nào.
  final String? activeWifiId;

  const DeviceNetworkInfo({
    this.currentSsid,
    this.currentSsidSource,
    this.rssiDbm,
    this.lastReportedAt,
    this.activeWifiId,
  });

  factory DeviceNetworkInfo.fromJson(Map<String, dynamic> json) {
    return DeviceNetworkInfo(
      currentSsid: json['currentSsid'] as String?,
      currentSsidSource: json['currentSsidSource'] as String?,
      rssiDbm: (json['rssiDbm'] as num?)?.toInt(),
      lastReportedAt: (json['lastReportedAt'] as num?)?.toInt(),
      activeWifiId: json['activeWifiId'] as String?,
    );
  }

  bool get hasSsid => (currentSsid?.trim().isNotEmpty ?? false);

  @override
  List<Object?> get props =>
      [currentSsid, currentSsidSource, rssiDbm, lastReportedAt, activeWifiId];
}

/// Một WiFi đã lưu cho thiết bị — phần tử của GET /wifi-list, hoặc kết quả
/// POST /wifi-add. Password KHÔNG bao giờ có trong response (security).
class SavedWifiNetwork extends Equatable {
  final String id;
  final String ssid;
  final String? label;

  /// true = entry chip đang dùng (tối đa 1 entry active per device).
  final bool active;
  final int? createdAt;

  const SavedWifiNetwork({
    required this.id,
    required this.ssid,
    this.label,
    required this.active,
    this.createdAt,
  });

  factory SavedWifiNetwork.fromJson(Map<String, dynamic> json) {
    return SavedWifiNetwork(
      id: json['id'] as String? ?? '',
      ssid: json['ssid'] as String? ?? '',
      label: json['label'] as String?,
      active: json['active'] as bool? ?? false,
      createdAt: (json['createdAt'] as num?)?.toInt(),
    );
  }

  bool get hasLabel => (label?.trim().isNotEmpty ?? false);

  @override
  List<Object?> get props => [id, ssid, label, active, createdAt];
}

/// Kết quả gọi POST /wifi-switch — endpoint long-running (5-60s).
enum WifiSwitchOutcome { switched, failed, timeout, offline }

class WifiSwitchResult extends Equatable {
  final WifiSwitchOutcome outcome;

  /// SSID chip đang ở sau khi gọi (currentSsid trong response).
  final String? currentSsid;

  /// SSID trước khi switch (chỉ có khi switched).
  final String? previousSsid;

  /// Mã lý do khi outcome=failed: auth_failure / no_ap_found / dhcp_timeout.
  final String? reason;

  const WifiSwitchResult({
    required this.outcome,
    this.currentSsid,
    this.previousSsid,
    this.reason,
  });

  factory WifiSwitchResult.switched({String? currentSsid, String? previousSsid}) =>
      WifiSwitchResult(
        outcome: WifiSwitchOutcome.switched,
        currentSsid: currentSsid,
        previousSsid: previousSsid,
      );

  factory WifiSwitchResult.failed({String? reason, String? currentSsid}) =>
      WifiSwitchResult(
        outcome: WifiSwitchOutcome.failed,
        reason: reason,
        currentSsid: currentSsid,
      );

  const WifiSwitchResult.timeout()
      : outcome = WifiSwitchOutcome.timeout,
        currentSsid = null,
        previousSsid = null,
        reason = null;

  const WifiSwitchResult.offline()
      : outcome = WifiSwitchOutcome.offline,
        currentSsid = null,
        previousSsid = null,
        reason = null;

  @override
  List<Object?> get props => [outcome, currentSsid, previousSsid, reason];
}
