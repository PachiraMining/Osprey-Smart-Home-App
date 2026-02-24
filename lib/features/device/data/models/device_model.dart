// lib/features/device/data/models/device_model.dart

import '../../domain/entities/device_entity.dart';

class DeviceModel extends DeviceEntity {
  const DeviceModel({
    required super.id,
    required super.name,
    required super.type,
    required super.status,
    super.connectionType,
    super.macAddress,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id']?['id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Unknown Device',
      type: json['type'] ?? 'default',
      status: _parseStatus(json),
      connectionType: _parseConnectionType(json),
      macAddress: json['label'] ?? json['additionalInfo']?['macAddress'],
    );
  }

  static String _parseStatus(Map<String, dynamic> json) {
    final active = json['active'];
    if (active == false) return 'offline';
    return 'online';
  }

  static String? _parseConnectionType(Map<String, dynamic> json) {
    return json['additionalInfo']?['connectionType'] ?? 'wifi';
  }
}
