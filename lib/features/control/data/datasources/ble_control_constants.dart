/// Hằng số riêng cho BLE Control Fallback (spec §5).
///
/// Tách khỏi `PairingConstants` vì char UUID là mới, còn lại tái dùng (brand,
/// service, status notify).
class BleControlConstants {
  BleControlConstants._();

  /// NEW characteristic — WRITE encrypted command + NOTIFY status.
  ///
  /// Slot `...381` (kế tiếp sau `DEVICE_UUID = ...380`). Firmware vendor
  /// xác nhận (commit `b098d912`, 2026-06-16) sau khi spec table có typo
  /// ghi nhầm `...37c` — `37c` là Pairing Service UUID, không phải char.
  ///
  /// Layout trong service `...37c`:
  /// ```
  /// ...37d  AUTH_CHALLENGE
  /// ...37e  PAIRING_DATA
  /// ...37f  STATUS_NOTIFY (CCCD)
  /// ...380  DEVICE_UUID
  /// ...381  BLE_CONTROL_CMD (CCCD)
  /// ```
  static const String bleControlCmdCharUuid =
      'a50133ef-ebd6-4a9b-8497-9d06309bf381';

  // ─── Timing ───────────────────────────────────────────────
  /// Quét tìm chip in-range trước khi quyết transport.
  static const Duration inRangeScanTimeout = Duration(seconds: 3);

  /// Connect + discover + subscribe — tối đa trong khoảng này.
  static const Duration setupTimeout = Duration(seconds: 8);

  /// Chờ NOTIFY sau khi WRITE 1 command.
  static const Duration notifyTimeout = Duration(seconds: 3);

  /// Idle disconnect — sau khoảng này không có lệnh, drop GATT để tiết kiệm pin.
  static const Duration idleDisconnect = Duration(seconds: 30);
}
