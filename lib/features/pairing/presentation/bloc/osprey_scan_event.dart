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

/// Internal — scan stream lỗi.
class OspreyScanFailedEvent extends OspreyScanEvent {
  final String message;
  const OspreyScanFailedEvent(this.message);

  @override
  List<Object?> get props => [message];
}
