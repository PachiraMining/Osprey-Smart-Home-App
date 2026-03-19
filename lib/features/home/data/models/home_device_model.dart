import '../../domain/entities/home_device_entity.dart';

class HomeDeviceModel extends HomeDeviceEntity {
  const HomeDeviceModel({
    required super.id,
    required super.smartHomeId,
    required super.deviceId,
    super.roomId,
    super.deviceName,
    super.sortOrder,
    super.originalName,
    super.deviceProfileId,
    super.type,
    super.isOnline,
  });

  factory HomeDeviceModel.fromJson(Map<String, dynamic> json) {
    return HomeDeviceModel(
      id: json['id'] is Map ? json['id']['id'] : (json['id'] ?? ''),
      smartHomeId: json['smartHomeId']?['id'] ?? '',
      deviceId: json['deviceId']?['id'] ?? json['deviceId'] ?? '',
      roomId: json['roomId']?['id'],
      deviceName: json['deviceName'],
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'roomId': roomId != null ? {'id': roomId, 'entityType': 'ROOM'} : null,
    if (deviceName != null) 'deviceName': deviceName,
    'sortOrder': sortOrder,
  };
}
