/// Transport user-facing đang dùng để control device.
enum TransportState {
  /// MQTT/RPC qua cloud — đường mặc định khi WiFi nhà ổn.
  cloud,

  /// BLE local fallback đang active — chip ngoài tầm cloud nhưng trong tầm BLE.
  /// UI hiển thị badge "Local control".
  bleFallback,

  /// Cả cloud lẫn BLE đều không khả thi → UI báo "Device unreachable".
  unreachable,
}
