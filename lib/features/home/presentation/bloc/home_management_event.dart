import 'package:equatable/equatable.dart';

sealed class HomeManagementEvent extends Equatable {
  const HomeManagementEvent();

  @override
  List<Object?> get props => [];
}

/// Load all homes for the current user
class LoadHomesEvent extends HomeManagementEvent {
  const LoadHomesEvent();
}

/// Select a home by id
class SelectHomeEvent extends HomeManagementEvent {
  final String homeId;
  const SelectHomeEvent(this.homeId);

  @override
  List<Object?> get props => [homeId];
}

/// Select a room filter — null means "Tất cả"
class SelectRoomEvent extends HomeManagementEvent {
  final String? roomId;
  const SelectRoomEvent(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// Create a new home
class CreateHomeEvent extends HomeManagementEvent {
  final String name;
  final String? geoName;
  const CreateHomeEvent({required this.name, this.geoName});

  @override
  List<Object?> get props => [name, geoName];
}

/// Update an existing home
class UpdateHomeEvent extends HomeManagementEvent {
  final String homeId;
  final String name;
  final String? geoName;
  const UpdateHomeEvent({
    required this.homeId,
    required this.name,
    this.geoName,
  });

  @override
  List<Object?> get props => [homeId, name, geoName];
}

/// Delete a home
class DeleteHomeEvent extends HomeManagementEvent {
  final String homeId;
  const DeleteHomeEvent(this.homeId);

  @override
  List<Object?> get props => [homeId];
}

/// Load devices belonging to a home
class LoadHomeDevicesEvent extends HomeManagementEvent {
  final String homeId;
  const LoadHomeDevicesEvent(this.homeId);

  @override
  List<Object?> get props => [homeId];
}

/// Add a device to a home
class AddDeviceToHomeEvent extends HomeManagementEvent {
  final String homeId;
  final String deviceId;
  const AddDeviceToHomeEvent({
    required this.homeId,
    required this.deviceId,
  });

  @override
  List<Object?> get props => [homeId, deviceId];
}

/// Update a device within a home (rename, assign room, etc.)
class UpdateHomeDeviceEvent extends HomeManagementEvent {
  final String homeId;
  final String deviceId;
  final String? roomId;
  final String? deviceName;
  const UpdateHomeDeviceEvent({
    required this.homeId,
    required this.deviceId,
    this.roomId,
    this.deviceName,
  });

  @override
  List<Object?> get props => [homeId, deviceId, roomId, deviceName];
}

/// Remove a device from a home
class RemoveDeviceFromHomeEvent extends HomeManagementEvent {
  final String homeId;
  final String deviceId;
  const RemoveDeviceFromHomeEvent({
    required this.homeId,
    required this.deviceId,
  });

  @override
  List<Object?> get props => [homeId, deviceId];
}

/// Load rooms for a home
class LoadRoomsEvent extends HomeManagementEvent {
  final String homeId;
  const LoadRoomsEvent(this.homeId);

  @override
  List<Object?> get props => [homeId];
}

/// Create a room within a home
class CreateRoomEvent extends HomeManagementEvent {
  final String homeId;
  final String name;
  final String? icon;
  const CreateRoomEvent({
    required this.homeId,
    required this.name,
    this.icon,
  });

  @override
  List<Object?> get props => [homeId, name, icon];
}

/// Update a room within a home
class UpdateRoomEvent extends HomeManagementEvent {
  final String homeId;
  final String roomId;
  final String name;
  final String? icon;
  const UpdateRoomEvent({
    required this.homeId,
    required this.roomId,
    required this.name,
    this.icon,
  });

  @override
  List<Object?> get props => [homeId, roomId, name, icon];
}

/// Delete a room from a home
class DeleteRoomEvent extends HomeManagementEvent {
  final String homeId;
  final String roomId;
  const DeleteRoomEvent({
    required this.homeId,
    required this.roomId,
  });

  @override
  List<Object?> get props => [homeId, roomId];
}
