import 'package:equatable/equatable.dart';

import '../../domain/entities/discovered_osprey_device.dart';

abstract class OspreyScanEvent extends Equatable {
  const OspreyScanEvent();

  @override
  List<Object?> get props => [];
}

class StartOspreyScanEvent extends OspreyScanEvent {
  const StartOspreyScanEvent();
}

class StopOspreyScanEvent extends OspreyScanEvent {
  const StopOspreyScanEvent();
}

/// Internal — emit từ scan stream subscription.
class OspreyDevicesUpdatedEvent extends OspreyScanEvent {
  final List<DiscoveredOspreyDevice> devices;
  const OspreyDevicesUpdatedEvent(this.devices);

  @override
  List<Object?> get props => [devices];
}

/// Internal — Bluetooth adapter bật/tắt.
class OspreyBluetoothChangedEvent extends OspreyScanEvent {
  final bool on;
  const OspreyBluetoothChangedEvent(this.on);

  @override
  List<Object?> get props => [on];
}

/// Internal — FBP báo scan bắt đầu/dừng (dừng = user stop HOẶC hết
/// scanTimeout tự dừng — trường hợp sau UI không có cách nào khác để biết).
class OspreyScanningChangedEvent extends OspreyScanEvent {
  final bool scanning;
  const OspreyScanningChangedEvent(this.scanning);

  @override
  List<Object?> get props => [scanning];
}

/// Internal — scan stream lỗi.
class OspreyScanFailedEvent extends OspreyScanEvent {
  final String message;
  const OspreyScanFailedEvent(this.message);

  @override
  List<Object?> get props => [message];
}
