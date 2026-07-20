import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/device_wifi_models.dart';

/// Lỗi nghiệp vụ WiFi mà UI cần phân biệt để hiển thị toast/dialog đúng.
enum DeviceWifiErrorCode {
  alreadySaved, // 400 "This SSID is already saved for this device"
  deleteActiveFirst, // 400 "Cannot delete active network — switch first"
  notFound, // 404
  forbidden, // 403 — không phải owner
  unauthorized, // 401 — JWT hết hạn
  serverConfig, // 500 — WiFi encryption not configured (ops issue)
  unknown,
}

class DeviceWifiException implements Exception {
  final DeviceWifiErrorCode code;
  final String message;
  const DeviceWifiException(this.code, this.message);

  @override
  String toString() => 'DeviceWifiException($code): $message';
}

/// Truy cập 5 endpoint WiFi của 1 thiết bị (chip).
///
/// Base URL + header X-Authorization do [ApiClient] lo. `deviceId` là TB
/// DeviceId UUID (lấy từ DeviceEntity.id), KHÔNG phải Osprey device_uuid.
class DeviceWifiRemoteDataSource {
  DeviceWifiRemoteDataSource({required this.apiClient});

  final ApiClient apiClient;

  /// Switch có thể mất 5-60s — set timeout rộng 90s theo spec.
  static const Duration _switchTimeout = Duration(seconds: 90);

  String _base(String deviceId) => ApiEndpoints.smartHomeDevice(deviceId);

  // ─── 1. GET /network-info ────────────────────────────────────
  Future<DeviceNetworkInfo> getNetworkInfo(String deviceId) async {
    try {
      final resp = await apiClient.get('${_base(deviceId)}/network-info');
      return DeviceNetworkInfo.fromJson(
        (resp.data as Map).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // ─── 2. GET /wifi-list ───────────────────────────────────────
  Future<List<SavedWifiNetwork>> getWifiList(String deviceId) async {
    try {
      final resp = await apiClient.get('${_base(deviceId)}/wifi-list');
      final list = (resp.data['wifiNetworks'] as List? ?? const [])
          .map((e) => SavedWifiNetwork.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
      return list;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // ─── 3. POST /wifi-add ───────────────────────────────────────
  Future<SavedWifiNetwork> addWifi(
    String deviceId, {
    required String ssid,
    required String password,
    String? label,
  }) async {
    try {
      final resp = await apiClient.post(
        '${_base(deviceId)}/wifi-add',
        data: {
          'ssid': ssid.trim(),
          'password': password,
          if (label != null && label.trim().isNotEmpty) 'label': label.trim(),
        },
      );
      return SavedWifiNetwork.fromJson(
        (resp.data as Map).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // ─── 4. DELETE /wifi/{wifiId} ────────────────────────────────
  Future<void> deleteWifi(String deviceId, String wifiId) async {
    try {
      await apiClient.delete('${_base(deviceId)}/wifi/$wifiId');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // ─── 5. POST /wifi-switch (long-running, 90s timeout) ────────
  Future<WifiSwitchResult> switchWifi(String deviceId, String wifiId) async {
    try {
      final resp = await apiClient.post(
        '${_base(deviceId)}/wifi-switch',
        data: {'wifiId': wifiId},
        options: Options(
          sendTimeout: _switchTimeout,
          receiveTimeout: _switchTimeout,
        ),
      );
      final body = (resp.data as Map).cast<String, dynamic>();
      final result = body['result'] as String?;
      if (result == 'switched') {
        return WifiSwitchResult.switched(
          currentSsid: body['currentSsid'] as String?,
          previousSsid: body['previousSsid'] as String?,
        );
      }
      if (result == 'failed') {
        return WifiSwitchResult.failed(
          reason: body['reason'] as String?,
          currentSsid: body['currentSsid'] as String?,
        );
      }
      // Server có thể trả timeout dưới dạng 200 trong vài cấu hình — phòng thủ.
      if (result == 'timeout') return const WifiSwitchResult.timeout();
      return WifiSwitchResult.failed(reason: null);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // 504 = backend hết thời gian chờ chip phản hồi.
      if (status == 504) return const WifiSwitchResult.timeout();
      // 400 = chip offline (switch chưa áp dụng tới khi chip online lại).
      if (status == 400) return const WifiSwitchResult.offline();
      // Client tự hết 90s mà không nhận phản hồi → coi như timeout.
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        return const WifiSwitchResult.timeout();
      }
      throw _mapError(e);
    }
  }

  // ─── Error mapping ───────────────────────────────────────────
  DeviceWifiException _mapError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final msg = (data is Map ? data['message'] as String? : null) ?? '';
    final lower = msg.toLowerCase();

    if (status == 401) {
      return const DeviceWifiException(
          DeviceWifiErrorCode.unauthorized, 'Session expired. Please sign in again.');
    }
    if (status == 403) {
      return const DeviceWifiException(
          DeviceWifiErrorCode.forbidden, 'You do not have access to this device.');
    }
    if (status == 404) {
      return DeviceWifiException(DeviceWifiErrorCode.notFound,
          msg.isNotEmpty ? msg : 'Not found.');
    }
    if (status == 400 && lower.contains('already saved')) {
      return DeviceWifiException(
          DeviceWifiErrorCode.alreadySaved, 'This network is already saved.');
    }
    if (status == 400 && lower.contains('active')) {
      return DeviceWifiException(DeviceWifiErrorCode.deleteActiveFirst,
          'Switch to another network before deleting this one.');
    }
    if (status == 500 && lower.contains('encryption')) {
      return const DeviceWifiException(DeviceWifiErrorCode.serverConfig,
          'Server is not configured for WiFi. Please contact support.');
    }
    return DeviceWifiException(
      DeviceWifiErrorCode.unknown,
      msg.isNotEmpty ? msg : 'Something went wrong. Please try again.',
    );
  }
}
