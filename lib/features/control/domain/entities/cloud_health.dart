/// Tình trạng đường MQTT/RPC đến backend.
enum CloudHealth {
  /// MQTT connected + probe gần nhất OK → cloud control khả dụng.
  online,

  /// MQTT vừa drop hoặc probe fail. Đang trong cửa sổ 10s grace
  /// (Rule B — bỏ qua transient flap). Vẫn coi như online cho UI.
  degraded,

  /// 10s liên tục không thấy cloud → chuyển sang BLE fallback nếu khả thi.
  down,
}
