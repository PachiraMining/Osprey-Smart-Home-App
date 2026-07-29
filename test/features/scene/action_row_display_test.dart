import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_curtain_app/core/error/failure.dart';
import 'package:smart_curtain_app/features/home/domain/entities/home_device_entity.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/data_point_entity.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/scene_action_entity.dart';
import 'package:smart_curtain_app/features/scene/domain/repositories/tap_to_run_repository.dart';
import 'package:smart_curtain_app/features/scene/domain/usecases/get_device_data_points.dart';
import 'package:smart_curtain_app/features/scene/presentation/utils/scene_action_display.dart';

class _MockRepo extends Mock implements TapToRunRepository {}

HomeDeviceEntity _device(String id, {String? profileId, String? type}) =>
    HomeDeviceEntity(
      id: 'row-$id',
      smartHomeId: 'home-1',
      deviceId: id,
      deviceName: 'Smart Curtain Track 17',
      deviceProfileId: profileId,
      type: type,
    );

const _curtainDps = [
  DataPointEntity(
    dpId: 1,
    code: 'control',
    name: 'Control',
    dpType: 'ENUM',
    mode: 'RW',
    constraints: {},
  ),
  DataPointEntity(
    dpId: 4,
    code: 'mode',
    name: 'Mode',
    dpType: 'ENUM',
    mode: 'RW',
    constraints: {},
  ),
];

void main() {
  group('actionFunctionLabel — dòng trên là "Chức năng: giá trị"', () {
    test('scene từ server (không có functionName) tra tên qua dpNames', () {
      const action = SceneActionEntity(
        actionType: 'DEVICE_CONTROL',
        entityId: 'dev-1',
        executorProperty: {'dpId': 1, 'dpValue': 'close'},
      );
      expect(actionFunctionLabel(action, {'dev-1:1': 'Control'}),
          'Control: close');
    });

    test('dpId 4 → Mode', () {
      const action = SceneActionEntity(
        actionType: 'DEVICE_CONTROL',
        entityId: 'dev-1',
        executorProperty: {'dpId': 4, 'dpValue': 'morning'},
      );
      expect(actionFunctionLabel(action, {'dev-1:4': 'Mode'}), 'Mode: morning');
    });

    test('functionName lưu sẵn trong action được ưu tiên', () {
      const action = SceneActionEntity(
        actionType: 'DEVICE_CONTROL',
        entityId: 'dev-1',
        executorProperty: {'dpId': 1, 'dpValue': 'open'},
        functionName: 'Control',
      );
      expect(actionFunctionLabel(action, const {}), 'Control: open');
    });

    test('BOOLEAN hiện On/Off thay vì true/false', () {
      const action = SceneActionEntity(
        actionType: 'DEVICE_CONTROL',
        entityId: 'dev-2',
        executorProperty: {'dpId': 7, 'dpValue': true},
        functionName: 'Switch',
      );
      expect(actionFunctionLabel(action, const {}), 'Switch: On');
    });

    test('hết cách mới fallback về dpId', () {
      const action = SceneActionEntity(
        actionType: 'DEVICE_CONTROL',
        entityId: 'dev-3',
        executorProperty: {'dpId': 9, 'dpValue': 'x'},
      );
      expect(actionFunctionLabel(action, const {}), 'dpId 9: x');
    });
  });

  group('resolveDpNames', () {
    late _MockRepo repo;
    late GetDeviceDataPoints useCase;

    setUp(() {
      repo = _MockRepo();
      useCase = GetDeviceDataPoints(repo);
    });

    test('tra dpId → tên từ datapoints của device profile', () async {
      when(() => repo.getDeviceDataPoints('profile-1'))
          .thenAnswer((_) async => const Right(_curtainDps));

      final names = await resolveDpNames(
        actions: const [
          SceneActionEntity(
            actionType: 'DEVICE_CONTROL',
            entityId: 'dev-1',
            executorProperty: {'dpId': 1, 'dpValue': 'close'},
          ),
        ],
        devices: [_device('dev-1', profileId: 'profile-1')],
        useCase: useCase,
      );

      expect(names['dev-1:1'], 'Control');
    });

    test('nhiều action cùng profile chỉ gọi API MỘT lần', () async {
      when(() => repo.getDeviceDataPoints('profile-1'))
          .thenAnswer((_) async => const Right(_curtainDps));

      final names = await resolveDpNames(
        actions: const [
          SceneActionEntity(
            actionType: 'DEVICE_CONTROL',
            entityId: 'dev-1',
            executorProperty: {'dpId': 1, 'dpValue': 'open'},
          ),
          SceneActionEntity(
            actionType: 'DEVICE_CONTROL',
            entityId: 'dev-1',
            executorProperty: {'dpId': 4, 'dpValue': 'night'},
          ),
        ],
        devices: [_device('dev-1', profileId: 'profile-1')],
        useCase: useCase,
      );

      expect(names, {'dev-1:1': 'Control', 'dev-1:4': 'Mode'});
      verify(() => repo.getDeviceDataPoints('profile-1')).called(1);
    });

    test('API lỗi → trả rỗng, KHÔNG ném (UI vẫn hiện fallback dpId)', () async {
      when(() => repo.getDeviceDataPoints(any())).thenAnswer(
        (_) async => const Left(ServerFailure('boom', message: 'boom')),
      );

      final names = await resolveDpNames(
        actions: const [
          SceneActionEntity(
            actionType: 'DEVICE_CONTROL',
            entityId: 'dev-1',
            executorProperty: {'dpId': 1, 'dpValue': 'open'},
          ),
        ],
        devices: [_device('dev-1', profileId: 'profile-1')],
        useCase: useCase,
      );

      expect(names, isEmpty);
    });
  });

  group('deviceOfAction', () {
    test('khớp theo entityId và nhận diện curtain track', () {
      const action = SceneActionEntity(
        actionType: 'DEVICE_CONTROL',
        entityId: 'dev-1',
        executorProperty: {'dpId': 1, 'dpValue': 'open'},
      );
      final live = deviceOfAction(
        action,
        [_device('dev-1', type: 'Osprey Smart Curtain Track')],
      );
      expect(live?.displayName, 'Smart Curtain Track 17');
      expect(live?.isCurtainTrack, isTrue);
    });

    test('thiết bị đã gỡ khỏi home → null', () {
      const action = SceneActionEntity(
        actionType: 'DEVICE_CONTROL',
        entityId: 'ghost',
        executorProperty: {'dpId': 1, 'dpValue': 'open'},
      );
      expect(deviceOfAction(action, [_device('dev-1')]), isNull);
    });
  });
}
