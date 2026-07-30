import 'dart:developer' as dev;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

/// Thông tin kỹ thuật hiện lên trang Device Information.
///
/// Backend KHÔNG lưu IP và MAC của thiết bị (kiểm tra 2026-07-30: `/network-info`
/// không có, `label`/`additionalInfo` của device đều null) nên hai mục đó không
/// hiển thị được — chỉ có những field dưới đây.
class DeviceTechInfo {
  /// UUID do chính thiết bị báo lên — tương đương "Virtual ID" của Tuya.
  final String? deviceUuid;
  final String? currentSsid;
  final int? rssiDbm;
  final String? firmwareVersion;

  /// `GET /firmware-update` → `updateAvailable`.
  final bool updateAvailable;

  const DeviceTechInfo({
    this.deviceUuid,
    this.currentSsid,
    this.rssiDbm,
    this.firmwareVersion,
    this.updateAvailable = false,
  });
}

class DeviceInfoService {
  final ApiClient apiClient;

  DeviceInfoService(this.apiClient);

  Future<DeviceTechInfo> fetch(String deviceId) async {
    final network = await _networkInfo(deviceId);
    final attributes = await _attributes(deviceId);
    final firmware = await _firmwareUpdate(deviceId);
    return DeviceTechInfo(
      deviceUuid: network['deviceUuid'] as String?,
      currentSsid: network['currentSsid'] as String?,
      rssiDbm: (network['rssiDbm'] as num?)?.toInt(),
      firmwareVersion: attributes['fw_version']?.toString(),
      updateAvailable: firmware['updateAvailable'] == true,
    );
  }

  Future<Map<String, dynamic>> _firmwareUpdate(String deviceId) async {
    try {
      final res = await apiClient.get(
        '/api/smarthome/devices/$deviceId/firmware-update',
      );
      final data = res.data;
      return data is Map<String, dynamic> ? data : const {};
    } catch (e) {
      dev.log('firmware-update failed: $e', name: 'deviceInfo');
      return const {};
    }
  }

  Future<Map<String, dynamic>> _networkInfo(String deviceId) async {
    try {
      final res =
          await apiClient.get(ApiEndpoints.deviceNetworkInfo(deviceId));
      final data = res.data;
      return data is Map<String, dynamic> ? data : const {};
    } catch (e) {
      dev.log('network-info failed: $e', name: 'deviceInfo');
      return const {};
    }
  }

  /// Attributes trả về dạng `[{key, value}, ...]` → gộp thành map.
  Future<Map<String, dynamic>> _attributes(String deviceId) async {
    try {
      final res = await apiClient.get(ApiEndpoints.deviceAttributes(deviceId));
      final data = res.data;
      if (data is! List) return const {};
      final out = <String, dynamic>{};
      for (final item in data) {
        if (item is Map && item['key'] is String) {
          out[item['key'] as String] = item['value'];
        }
      }
      return out;
    } catch (e) {
      dev.log('attributes failed: $e', name: 'deviceInfo');
      return const {};
    }
  }
}
