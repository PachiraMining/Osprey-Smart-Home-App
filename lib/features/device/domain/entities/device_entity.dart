// lib/features/device/domain/entities/device_entity.dart

import 'package:equatable/equatable.dart';

class DeviceEntity extends Equatable {
  final String id;
  final String name;
  final String type;
  final String status; // "online", "offline", "bluetooth_offline"
  final String? connectionType; // "wifi", "bluetooth", "zigbee"
  final String? macAddress;
  final String? icon;
  final DateTime? lastSeen;
  final Map<String, dynamic>? metadata;

  const DeviceEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.connectionType,
    this.macAddress,
    this.icon,
    this.lastSeen,
    this.metadata,
  });

  bool get isOnline => status == 'online';
  bool get isOffline => status == 'offline' || status == 'bluetooth_offline';

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    status,
    connectionType,
    macAddress,
    icon,
    lastSeen,
    metadata,
  ];
}
