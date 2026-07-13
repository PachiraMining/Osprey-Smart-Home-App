/// Kết quả xử lý 1 lệnh BLE Control (parse từ NOTIFY byte §5.3 + sentinel app-side).
enum BleControlResult {
  /// Notify 0x00 — chip xác nhận motor đã nhận lệnh.
  ok,

  /// Notify 0x01 — chip không decrypt được (key sai hoặc tag mismatch).
  /// App phải xoá session key cũ + flow re-pair.
  decryptFailed,

  /// Notify 0x02 — counter cũ hoặc bằng counter chip → chip nghi replay attack.
  /// Thường gặp khi user wipe app data → counter mất; flow re-pair.
  replayRejected,

  /// Notify 0x03 — JSON parse OK nhưng cmd không phải open/close/stop/pct.
  unknownCommand,

  /// Notify 0x04 — MCU motor reject (đang busy / error).
  motorBusy,

  /// Byte trả về không nằm trong 0x00..0x04 — coi như firmware bug.
  unknownStatus,

  /// App-side: GATT connect/write/notify timeout (chip ngoài tầm hoặc đang
  /// connected với phone khác — chỉ 1 BLE central allowed, §9 case 1).
  transportTimeout,

  /// App-side: chưa có session lưu cho device (chưa pair hoặc đã clear).
  notPaired,
}
