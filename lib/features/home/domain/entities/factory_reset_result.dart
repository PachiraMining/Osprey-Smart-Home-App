import 'package:equatable/equatable.dart';

/// Kết quả của factory-reset thiết bị (Nút "Hủy liên kết và xóa dữ liệu").
///
/// Backend trả về sau khi gửi RPC factoryReset + cascade delete:
/// `{ status, deviceWasOnline, deviceUuid, cleanedUpAt }`.
class FactoryResetResult extends Equatable {
  /// Thiết bị có online lúc reset không.
  /// - online: nhận RPC → wipe ~5s → pairing mode
  /// - offline: J2 watchdog ~90s mới wipe
  final bool deviceWasOnline;

  final String deviceUuid;

  const FactoryResetResult({
    required this.deviceWasOnline,
    required this.deviceUuid,
  });

  @override
  List<Object?> get props => [deviceWasOnline, deviceUuid];
}
