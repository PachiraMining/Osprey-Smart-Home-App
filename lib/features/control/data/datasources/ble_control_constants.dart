/// Hằng số riêng cho BLE Control Fallback (spec §5).
///
/// Tách khỏi `PairingConstants` vì char UUID là mới, còn lại tái dùng (brand,
/// service, status notify).
class BleControlConstants {
  BleControlConstants._();

  /// NEW characteristic — WRITE encrypted command + NOTIFY status.
  ///
  /// **GHI CHÚ**: Spec gốc §5 bảng characteristics ghi UUID `...37c` cho
  /// `BLE_CONTROL_CMD`, NHƯNG `...37c` đã là Pairing Service UUID
  /// (xem `PairingConstants.pairingServiceUuid`) — đây là lỗi trong spec.
  /// Theo convention chuỗi char hiện hữu của firmware (`...37d`/`37e`/`37f`/
  /// `380`), char mới sẽ ở slot kế tiếp `...381`.
  ///
  /// **TODO**: Xác nhận lại với firmware team Vietlam khi họ ship build mới
  /// (~3-4 ngày sau 2026-06-16) — nếu họ chốt UUID khác, cập nhật ở đây.
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
