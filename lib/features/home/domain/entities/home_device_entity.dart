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

  /// Loại thiết bị theo device profile từ backend
  /// (`GET /api/device/info/{id}` → `type`, vd 'Osprey Smart Curtain Track';
  /// thiết bị chưa gán profile là 'Default'). Chỉ curtain track mới được
  /// hiển thị artwork rèm.
  bool get isCurtainTrack =>
      (type ?? '').toLowerCase().contains('curtain');

  /// Display name: backend đảm bảo deviceName non-null (Tuya pattern,
  /// update 2026-06-05) — vẫn guard null/rỗng phòng backend regress.
  String get displayName {
    final name = deviceName;
    if (name != null && name.isNotEmpty) return name;
    return originalName ?? deviceId;
  }

  /// Immutable copy overriding the user-editable fields (rename / room / order).
  /// Preserves enrichment (type, isOnline, …). A field left null keeps current.
  HomeDeviceEntity copyWith({
    String? roomId,
    String? deviceName,
    int? sortOrder,
  }) => HomeDeviceEntity(
        id: id,
        smartHomeId: smartHomeId,
        deviceId: deviceId,
        roomId: roomId ?? this.roomId,
        deviceName: deviceName ?? this.deviceName,
        sortOrder: sortOrder ?? this.sortOrder,
        originalName: originalName,
        deviceProfileId: deviceProfileId,
        type: type,
        isOnline: isOnline,
      );

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
