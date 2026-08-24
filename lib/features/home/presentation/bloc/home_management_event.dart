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

  /// IANA timezone id for the home. When null the bloc stamps the device's
  /// current zone so the scheduler fires scenes in local time.
  final String? timezone;
  const CreateHomeEvent({required this.name, this.geoName, this.timezone});

  @override
  List<Object?> get props => [name, geoName, timezone];
}

/// Update an existing home
class UpdateHomeEvent extends HomeManagementEvent {
  final String homeId;
  final String name;
  final String? geoName;
  final double? latitude;
  final double? longitude;

  /// IANA timezone id. When provided, the backend re-syncs every AUTOMATION
  /// scene of the home to the new zone.
  final String? timezone;
  const UpdateHomeEvent({
    required this.homeId,
    required this.name,
    this.geoName,
    this.latitude,
    this.longitude,
    this.timezone,
  });

  @override
  List<Object?> get props =>
      [homeId, name, geoName, latitude, longitude, timezone];
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
///
/// LƯU Ý: PUT backend là full-replace — caller PHẢI truyền cả roomId và
/// sortOrder hiện tại khi chỉ muốn rename, nếu không backend sẽ reset
/// 2 field đó (văng device khỏi room).
class UpdateHomeDeviceEvent extends HomeManagementEvent {
  final String homeId;
  final String deviceId;
  final String? roomId;
  final String? deviceName;
  final int? sortOrder;
  const UpdateHomeDeviceEvent({
    required this.homeId,
    required this.deviceId,
    this.roomId,
    this.deviceName,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [homeId, deviceId, roomId, deviceName, sortOrder];
}

/// Nút "Ngắt kết nối" — DELETE device khỏi home (không gửi RPC factoryReset).
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

/// Nút "Hủy liên kết và xóa dữ liệu" — POST factory-reset (gửi RPC tới chip).
class FactoryResetDeviceEvent extends HomeManagementEvent {
  final String homeId;
  final String deviceId;
  const FactoryResetDeviceEvent({
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

  /// PUT của backend là full-replace, nên khi đổi tên vẫn phải gửi kèm thứ tự
  /// hiện tại, nếu không phòng sẽ bị đẩy về đầu danh sách.
  final int? sortOrder;

  const UpdateRoomEvent({
    required this.homeId,
    required this.roomId,
    required this.name,
    this.icon,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [homeId, roomId, name, icon, sortOrder];
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

/// Poll trạng thái online của thiết bị vừa pair xong: backend trả PAIRED
/// trước khi ThingsBoard set server attribute `active=true`, nên snapshot
/// devices đầu tiên luôn thấy offline. Event này chờ TB xác nhận rồi patch
/// đúng 1 thiết bị vào state (không reload cả list).
class WaitDeviceOnlineEvent extends HomeManagementEvent {
  final String deviceId;
  final Duration interval;
  final int maxAttempts;

  /// Hiện online NGAY khi thiết bị xuất hiện trong list (PAIRED chứng tỏ nó
  /// vừa gọi backend qua WiFi thành công) — poll chỉ để xác nhận; nếu hết
  /// [maxAttempts] mà TB vẫn không thấy device thì revert về offline.
  final bool optimistic;

  const WaitDeviceOnlineEvent(
    this.deviceId, {
    this.interval = const Duration(seconds: 3),
    this.maxAttempts = 10,
    this.optimistic = false,
  });

  @override
  List<Object?> get props => [deviceId, interval, maxAttempts, optimistic];
}
