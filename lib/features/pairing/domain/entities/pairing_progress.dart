import 'package:equatable/equatable.dart';

/// Các bước trong pairing flow (Option 2 — đọc DEVICE_UUID qua GATT).
///
/// Thứ tự runtime: connect + READ DEVICE_UUID trước (READ disarm firmware
/// watchdog 30s), sau đó backend calls thoải mái thời gian.
enum PairingStep {
  /// GATT connect + MTU + subscribe STATUS_NOTIFY + READ DEVICE_UUID.
  connecting,

  /// POST /pairing/auth-challenge + POST /pairing/token (sau khi disarm).
  requestingToken,

  /// WRITE AUTH_CHALLENGE + chờ AUTH_OK.
  authenticating,

  /// Encrypt + WRITE PAIRING_DATA + chờ DATA_OK.
  sendingWifiCredentials,

  /// Disconnect BLE, poll backend đến khi status = PAIRED.
  waitingForDevice,

  /// PAIRED — device đã lên cloud và bind vào home.
  done,
}

/// Tiến trình pairing — emit qua Stream từ repository về BLoC.
class PairingProgress extends Equatable {
  final PairingStep step;

  /// TB device id, chỉ có khi [step] == [PairingStep.done].
  final String? deviceId;

  const PairingProgress(this.step, {this.deviceId});

  @override
  List<Object?> get props => [step, deviceId];
}
