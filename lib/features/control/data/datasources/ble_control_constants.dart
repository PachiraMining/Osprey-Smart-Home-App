/// Hằng số riêng cho BLE Control Fallback (spec §5).
///
/// Tách khỏi `PairingConstants` vì char UUID là mới, còn lại tái dùng (brand,
/// service, status notify).
class BleControlConstants {
  BleControlConstants._();

  /// NEW characteristic — WRITE encrypted command + NOTIFY status.
  ///
  /// UUID trùng với Pairing Service UUID (`...37c`) — đây là chọn intentional
  /// của firmware (xác nhận trong spec v2 commit ab34570d, 2026-06-16):
  /// BLE_CONTROL_CMD characteristic nằm trong service `37c` và mang chính
  /// UUID `37c`. flutter_blue_plus phân biệt được vì discover qua
  /// `svc.characteristics` (level khác với service discovery).
  static const String bleControlCmdCharUuid =
      'a50133ef-ebd6-4a9b-8497-9d06309bf37c';

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
