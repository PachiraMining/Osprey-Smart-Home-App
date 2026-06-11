import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Lưu/đọc SSID mà app đã cấu hình cho từng thiết bị lúc pairing.
///
/// Firmware KHÔNG báo SSID/RSSI lên ThingsBoard (đã verify qua Debug API:
/// device info + attributes + timeseries đều không có), nên nguồn "thật" duy
/// nhất cho SSID là chính chuỗi app gửi qua BLE lúc ghép nối. Lưu local theo
/// deviceId để màn Device Network hiển thị lại.
class DeviceNetworkStore {
  DeviceNetworkStore(this._storage);

  final FlutterSecureStorage _storage;

  static String _key(String deviceId) => 'device_ssid_$deviceId';

  /// Lưu SSID đã provision cho [deviceId]. Bỏ qua nếu rỗng.
  Future<void> saveSsid(String deviceId, String ssid) async {
    final trimmed = ssid.trim();
    if (deviceId.isEmpty || trimmed.isEmpty) return;
    await _storage.write(key: _key(deviceId), value: trimmed);
  }

  /// Đọc SSID đã lưu cho [deviceId], hoặc null nếu chưa từng lưu.
  Future<String?> getSsid(String deviceId) async {
    if (deviceId.isEmpty) return null;
    return _storage.read(key: _key(deviceId));
  }
}
