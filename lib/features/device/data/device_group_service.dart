import 'dart:developer' as dev;

import '../../../core/network/api_client.dart';

/// Nhóm thiết bị (`DeviceGroup`) — gộp các thiết bị CÙNG device profile để
/// điều khiển chung.
class DeviceGroup {
  final String id;
  final String name;
  final String? deviceProfileId;

  const DeviceGroup({
    required this.id,
    required this.name,
    this.deviceProfileId,
  });

  factory DeviceGroup.fromJson(Map<String, dynamic> json) => DeviceGroup(
        id: json['id'] is Map ? json['id']['id'] ?? '' : (json['id'] ?? ''),
        name: json['name'] ?? '',
        deviceProfileId: json['deviceProfileId'] is Map
            ? json['deviceProfileId']['id'] as String?
            : json['deviceProfileId'] as String?,
      );
}

/// Bọc các endpoint group. Lưu ý: backend CHƯA có endpoint gửi lệnh cho cả
/// nhóm, nên phần điều khiển vẫn phải lặp qua từng thiết bị.
class DeviceGroupService {
  final ApiClient apiClient;

  DeviceGroupService(this.apiClient);

  Future<List<DeviceGroup>> groupsOfHome(String homeId) async {
    try {
      final res =
          await apiClient.get('/api/smarthome/homes/$homeId/groups');
      final data = res.data;
      if (data is! List) return const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(DeviceGroup.fromJson)
          .toList();
    } catch (e) {
      dev.log('groupsOfHome failed: $e', name: 'group');
      return const [];
    }
  }

  /// Tạo nhóm rồi nạp thiết bị vào. Trả `null` nếu tạo thất bại.
  Future<DeviceGroup?> createGroup({
    required String homeId,
    required String name,
    required String deviceProfileId,
    required List<String> deviceIds,
  }) async {
    try {
      final res = await apiClient.post(
        '/api/smarthome/groups',
        data: {
          'smartHomeId': {'id': homeId, 'entityType': 'SMART_HOME'},
          'name': name,
          'deviceProfileId': {
            'id': deviceProfileId,
            'entityType': 'DEVICE_PROFILE',
          },
        },
      );
      final data = res.data;
      if (data is! Map<String, dynamic>) return null;
      final group = DeviceGroup.fromJson(data);
      for (final deviceId in deviceIds) {
        await addDevice(groupId: group.id, deviceId: deviceId);
      }
      return group;
    } catch (e) {
      dev.log('createGroup failed: $e', name: 'group');
      return null;
    }
  }

  Future<bool> addDevice({
    required String groupId,
    required String deviceId,
  }) async {
    try {
      await apiClient.post(
        '/api/smarthome/groups/$groupId/devices',
        data: {
          'groupId': {'id': groupId, 'entityType': 'DEVICE_GROUP'},
          'deviceId': {'id': deviceId, 'entityType': 'DEVICE'},
        },
      );
      return true;
    } catch (e) {
      dev.log('addDevice failed: $e', name: 'group');
      return false;
    }
  }

  Future<bool> deleteGroup(String groupId) async {
    try {
      await apiClient.delete('/api/smarthome/groups/$groupId');
      return true;
    } catch (e) {
      dev.log('deleteGroup failed: $e', name: 'group');
      return false;
    }
  }
}
