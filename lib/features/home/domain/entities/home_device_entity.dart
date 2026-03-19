import 'package:equatable/equatable.dart';

class HomeDeviceEntity extends Equatable {
  final String id;
  final String smartHomeId;
  final String deviceId;
  final String? roomId;
  final String? deviceName;
  final int sortOrder;
  // Enriched fields (from GET /api/device/{deviceId})
  final String? originalName;
  final String? deviceProfileId;
  final String? type;
  final bool? isOnline;

  const HomeDeviceEntity({
    required this.id,
    required this.smartHomeId,
    required this.deviceId,
    this.roomId,
    this.deviceName,
    this.sortOrder = 0,
    this.originalName,
    this.deviceProfileId,
    this.type,
    this.isOnline,
  });

  /// Display name: custom name > original name > deviceId
  String get displayName => deviceName ?? originalName ?? deviceId;

  HomeDeviceEntity copyWithDeviceInfo({
    String? originalName,
    String? deviceProfileId,
    String? type,
    bool? isOnline,
  }) => HomeDeviceEntity(
    id: id,
    smartHomeId: smartHomeId,
    deviceId: deviceId,
    roomId: roomId,
    deviceName: deviceName,
    sortOrder: sortOrder,
    originalName: originalName ?? this.originalName,
    deviceProfileId: deviceProfileId ?? this.deviceProfileId,
    type: type ?? this.type,
    isOnline: isOnline ?? this.isOnline,
  );

  @override
  List<Object?> get props => [id, smartHomeId, deviceId, roomId, deviceName, sortOrder, originalName, deviceProfileId, type, isOnline];
}
