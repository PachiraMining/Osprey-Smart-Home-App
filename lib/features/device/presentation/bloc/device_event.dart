import 'package:equatable/equatable.dart';

abstract class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object?> get props => [];
}

class LoadDevicesEvent extends DeviceEvent {}

class DeleteDeviceEvent extends DeviceEvent {
  final String deviceId;

  const DeleteDeviceEvent(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class RefreshDevicesEvent extends DeviceEvent {}
