import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/scene/data/models/automation_scene_model.dart';
import 'package:smart_curtain_app/features/scene/data/models/effective_time_model.dart';
import 'package:smart_curtain_app/features/scene/data/models/schedule_condition_model.dart';
import 'package:smart_curtain_app/features/scene/data/repositories/automation_repository_impl.dart';
import 'package:smart_curtain_app/features/scene/data/datasources/automation_remote_datasource.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/effective_time_entity.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/scene_action_entity.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/schedule_condition_entity.dart';

/// Captures the last body sent to createAutomation/updateAutomation so tests can
/// assert what the app actually PUTs to the backend.
class _CapturingDataSource implements AutomationRemoteDataSource {
  Map<String, dynamic>? lastBody;

  @override
  Future<AutomationSceneModel> createAutomation(
      String homeId, Map<String, dynamic> body) async {
    lastBody = body;
    return AutomationSceneModel.fromJson(const {});
  }

  @override
  Future<AutomationSceneModel> updateAutomation(
      String sceneId, Map<String, dynamic> body) async {
    lastBody = body;
    return AutomationSceneModel.fromJson(const {});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not stubbed');
}

void main() {
  group('ScheduleConditionModel timezone', () {
    test('fromJson without timeZoneId → null (no VN default)', () {
      final m = ScheduleConditionModel.fromJson({
        'conditionType': 'SCHEDULE',
        'loops': '1111111',
        'time': '18:00',
      });
      expect(m.timeZoneId, isNull);
    });

    test('toJson omits timeZoneId when null', () {
      const m = ScheduleConditionModel(
        conditionType: 'SCHEDULE',
        loops: '1111111',
        time: '18:00',
      );
      expect(m.toJson().containsKey('timeZoneId'), isFalse);
    });

    test('an explicit override round-trips', () {
      final m = ScheduleConditionModel.fromJson({
        'conditionType': 'SCHEDULE',
        'loops': '1111111',
        'time': '18:00',
        'timeZoneId': 'America/New_York',
      });
      expect(m.timeZoneId, 'America/New_York');
      expect(m.toJson()['timeZoneId'], 'America/New_York');
    });
  });

  group('EffectiveTimeModel timezone', () {
    test('fromJson without timeZoneId → null', () {
      final m = EffectiveTimeModel.fromJson({'type': 'ALL_DAY'});
      expect(m.timeZoneId, isNull);
    });

    test('toJson omits timeZoneId when null', () {
      const m = EffectiveTimeModel(type: 'ALL_DAY');
      expect(m.toJson().containsKey('timeZoneId'), isFalse);
    });
  });

  group('AutomationRepositoryImpl body', () {
    late _CapturingDataSource ds;
    late AutomationRepositoryImpl repo;

    setUp(() {
      ds = _CapturingDataSource();
      repo = AutomationRepositoryImpl(remoteDataSource: ds);
    });

    test(
        'createAutomation strips a legacy VN timeZoneId so the backend derives '
        'from home.timezone', () async {
      await repo.createAutomation(
        homeId: 'home-1',
        name: 'Evening lights',
        conditions: const [
          ScheduleConditionEntity(
            conditionType: 'SCHEDULE',
            timeZoneId: 'Asia/Ho_Chi_Minh', // legacy value carried from backend
            loops: '1111111',
            time: '18:00',
          ),
        ],
        conditionLogic: 'AND',
        effectiveTime: const EffectiveTimeEntity(
          type: 'ALL_DAY',
          timeZoneId: 'Asia/Ho_Chi_Minh',
        ),
        actions: const [
          SceneActionEntity(
            actionType: 'DEVICE_CONTROL',
            entityId: 'device-1',
            executorProperty: {'dpId': 1, 'dpValue': 'on'},
          ),
        ],
      );

      final body = ds.lastBody!;
      final condition = (body['conditions'] as List).first as Map;
      expect(condition.containsKey('timeZoneId'), isFalse,
          reason: 'condition must not override home.timezone');
      final effective = body['effectiveTime'] as Map;
      expect(effective.containsKey('timeZoneId'), isFalse,
          reason: 'effectiveTime must not override home.timezone');
    });
  });
}
