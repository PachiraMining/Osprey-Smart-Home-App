// Round-trip JSON serializers used ONLY for on-device caching (hydrated_bloc).
//
// The data-layer `Model.toJson()` methods are for API REQUESTS and drop fields
// we need to render (id, isOnline, type, …), so caching needs its own complete
// serializers. These return plain domain entities — enough to paint the last
// known lists instantly on cold start, before fresh data revalidates.

import '../../features/home/domain/entities/home_device_entity.dart';
import '../../features/home/domain/entities/home_entity.dart';
import '../../features/home/domain/entities/room_entity.dart';
import '../../features/scene/domain/entities/automation_scene_entity.dart';
import '../../features/scene/domain/entities/effective_time_entity.dart';
import '../../features/scene/domain/entities/scene_action_entity.dart';
import '../../features/scene/domain/entities/schedule_condition_entity.dart';
import '../../features/scene/domain/entities/tap_to_run_scene_entity.dart';

// ─── Home ───────────────────────────────────────────────────────────────
Map<String, dynamic> homeToJson(HomeEntity h) => {
      'id': h.id,
      'name': h.name,
      'ownerUserId': h.ownerUserId,
      'geoName': h.geoName,
      'latitude': h.latitude,
      'longitude': h.longitude,
      'timezone': h.timezone,
    };

HomeEntity homeFromJson(Map<String, dynamic> j) => HomeEntity(
      id: j['id'] as String? ?? '',
      name: j['name'] as String? ?? '',
      ownerUserId: j['ownerUserId'] as String?,
      geoName: j['geoName'] as String?,
      latitude: (j['latitude'] as num?)?.toDouble(),
      longitude: (j['longitude'] as num?)?.toDouble(),
      timezone: j['timezone'] as String?,
    );

// ─── Room ───────────────────────────────────────────────────────────────
Map<String, dynamic> roomToJson(RoomEntity r) => {
      'id': r.id,
      'name': r.name,
      'icon': r.icon,
      'sortOrder': r.sortOrder,
    };

RoomEntity roomFromJson(Map<String, dynamic> j) => RoomEntity(
      id: j['id'] as String? ?? '',
      name: j['name'] as String? ?? '',
      icon: j['icon'] as String?,
      sortOrder: j['sortOrder'] as int? ?? 0,
    );

// ─── Home device (enriched) ─────────────────────────────────────────────
Map<String, dynamic> deviceToJson(HomeDeviceEntity d) => {
      'id': d.id,
      'smartHomeId': d.smartHomeId,
      'deviceId': d.deviceId,
      'roomId': d.roomId,
      'deviceName': d.deviceName,
      'sortOrder': d.sortOrder,
      'originalName': d.originalName,
      'deviceProfileId': d.deviceProfileId,
      'type': d.type,
      'isOnline': d.isOnline,
    };

HomeDeviceEntity deviceFromJson(Map<String, dynamic> j) => HomeDeviceEntity(
      id: j['id'] as String? ?? '',
      smartHomeId: j['smartHomeId'] as String? ?? '',
      deviceId: j['deviceId'] as String? ?? '',
      roomId: j['roomId'] as String?,
      deviceName: j['deviceName'] as String?,
      sortOrder: j['sortOrder'] as int? ?? 0,
      originalName: j['originalName'] as String?,
      deviceProfileId: j['deviceProfileId'] as String?,
      type: j['type'] as String?,
      isOnline: j['isOnline'] as bool?,
    );

// ─── Scene action ───────────────────────────────────────────────────────
Map<String, dynamic> actionToJson(SceneActionEntity a) => {
      'actionType': a.actionType,
      'entityId': a.entityId,
      'executorProperty': a.executorProperty,
      'deviceName': a.deviceName,
      'functionName': a.functionName,
    };

SceneActionEntity actionFromJson(Map<String, dynamic> j) => SceneActionEntity(
      actionType: j['actionType'] as String? ?? '',
      entityId: j['entityId'] as String?,
      executorProperty: (j['executorProperty'] as Map?)?.cast<String, dynamic>(),
      deviceName: j['deviceName'] as String?,
      functionName: j['functionName'] as String?,
    );

// ─── Schedule condition ─────────────────────────────────────────────────
Map<String, dynamic> conditionToJson(ScheduleConditionEntity c) => {
      'conditionType': c.conditionType,
      'timeZoneId': c.timeZoneId,
      'loops': c.loops,
      'time': c.time,
      'date': c.date,
    };

ScheduleConditionEntity conditionFromJson(Map<String, dynamic> j) =>
    ScheduleConditionEntity(
      conditionType: j['conditionType'] as String? ?? 'SCHEDULE',
      timeZoneId: j['timeZoneId'] as String?,
      loops: j['loops'] as String? ?? '0000000',
      time: j['time'] as String? ?? '00:00',
      date: j['date'] as String?,
    );

// ─── Effective time ─────────────────────────────────────────────────────
Map<String, dynamic> effectiveTimeToJson(EffectiveTimeEntity e) => {
      'type': e.type,
      'startTime': e.startTime,
      'endTime': e.endTime,
      'loops': e.loops,
      'timeZoneId': e.timeZoneId,
    };

EffectiveTimeEntity effectiveTimeFromJson(Map<String, dynamic> j) =>
    EffectiveTimeEntity(
      type: j['type'] as String? ?? 'ALL_DAY',
      startTime: j['startTime'] as String?,
      endTime: j['endTime'] as String?,
      loops: j['loops'] as String?,
      timeZoneId: j['timeZoneId'] as String?,
    );

// ─── Tap-to-Run scene ───────────────────────────────────────────────────
Map<String, dynamic> tapToRunToJson(TapToRunSceneEntity s) => {
      'id': s.id,
      'name': s.name,
      'sceneType': s.sceneType,
      'icon': s.icon,
      'enabled': s.enabled,
      'actions': s.actions.map(actionToJson).toList(),
    };

TapToRunSceneEntity tapToRunFromJson(Map<String, dynamic> j) =>
    TapToRunSceneEntity(
      id: j['id'] as String? ?? '',
      name: j['name'] as String? ?? '',
      sceneType: j['sceneType'] as String? ?? 'TAP_TO_RUN',
      icon: j['icon'] as String?,
      enabled: j['enabled'] as bool? ?? true,
      actions: ((j['actions'] as List?) ?? const [])
          .whereType<Map>()
          .map((a) => actionFromJson(a.cast<String, dynamic>()))
          .toList(),
    );

// ─── Automation scene ───────────────────────────────────────────────────
Map<String, dynamic> automationToJson(AutomationSceneEntity a) => {
      'id': a.id,
      'name': a.name,
      'sceneType': a.sceneType,
      'icon': a.icon,
      'enabled': a.enabled,
      'conditionLogic': a.conditionLogic,
      'conditions': a.conditions.map(conditionToJson).toList(),
      'effectiveTime':
          a.effectiveTime == null ? null : effectiveTimeToJson(a.effectiveTime!),
      'actions': a.actions.map(actionToJson).toList(),
    };

AutomationSceneEntity automationFromJson(Map<String, dynamic> j) =>
    AutomationSceneEntity(
      id: j['id'] as String? ?? '',
      name: j['name'] as String? ?? '',
      sceneType: j['sceneType'] as String? ?? 'AUTOMATION',
      icon: j['icon'] as String?,
      enabled: j['enabled'] as bool? ?? true,
      conditionLogic: j['conditionLogic'] as String? ?? 'AND',
      conditions: ((j['conditions'] as List?) ?? const [])
          .whereType<Map>()
          .map((c) => conditionFromJson(c.cast<String, dynamic>()))
          .toList(),
      effectiveTime: j['effectiveTime'] == null
          ? null
          : effectiveTimeFromJson(
              (j['effectiveTime'] as Map).cast<String, dynamic>()),
      actions: ((j['actions'] as List?) ?? const [])
          .whereType<Map>()
          .map((a) => actionFromJson(a.cast<String, dynamic>()))
          .toList(),
    );
