import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_curtain_app/core/error/failure.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/automation_scene_entity.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/effective_time_entity.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/scene_action_entity.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/schedule_condition_entity.dart';
import 'package:smart_curtain_app/features/scene/domain/repositories/automation_repository.dart';
import 'package:smart_curtain_app/features/scene/domain/usecases/create_automation.dart';
import 'package:smart_curtain_app/features/scene/domain/usecases/delete_automation.dart';
import 'package:smart_curtain_app/features/scene/domain/usecases/get_automations.dart';
import 'package:smart_curtain_app/features/scene/domain/usecases/toggle_automation.dart';
import 'package:smart_curtain_app/features/scene/domain/usecases/update_automation.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/automation/automation_bloc.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/automation/automation_event.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/automation/automation_state.dart';

/// Fake repository that records the homeId passed to createAutomation so we can
/// prove the bloc seeds it from LoadAutomationsEvent (the wiring that makes the
/// detail page's create flow actually target a home instead of failing).
class _FakeAutomationRepository implements AutomationRepository {
  final List<AutomationSceneEntity> automations;
  String? lastCreateHomeId;

  _FakeAutomationRepository({this.automations = const []});

  @override
  Future<Either<Failure, List<AutomationSceneEntity>>> getAutomations(
          String homeId) async =>
      Right(automations);

  @override
  Future<Either<Failure, AutomationSceneEntity>> createAutomation({
    required String homeId,
    required String name,
    String? icon,
    required List<ScheduleConditionEntity> conditions,
    required String conditionLogic,
    EffectiveTimeEntity? effectiveTime,
    required List<SceneActionEntity> actions,
  }) async {
    lastCreateHomeId = homeId;
    return Right(AutomationSceneEntity(
      id: 'new-id',
      name: name,
      sceneType: 'AUTOMATION',
      enabled: true,
      conditions: conditions,
      conditionLogic: conditionLogic,
      actions: actions,
    ));
  }

  @override
  Future<Either<Failure, AutomationSceneEntity>> getAutomationDetail(
          String sceneId) async =>
      Left(ServerFailure('not used', message: 'not used'));

  @override
  Future<Either<Failure, AutomationSceneEntity>> updateAutomation({
    required String sceneId,
    required String name,
    String? icon,
    required bool enabled,
    required List<ScheduleConditionEntity> conditions,
    required String conditionLogic,
    EffectiveTimeEntity? effectiveTime,
    required List<SceneActionEntity> actions,
  }) async =>
      Left(ServerFailure('not used', message: 'not used'));

  @override
  Future<Either<Failure, void>> deleteAutomation(String sceneId) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> toggleAutomation(
          String sceneId, bool enabled) async =>
      const Right(null);
}

AutomationBloc _blocFor(_FakeAutomationRepository repo) => AutomationBloc(
      getAutomations: GetAutomations(repo),
      createAutomation: CreateAutomation(repo),
      updateAutomation: UpdateAutomation(repo),
      deleteAutomation: DeleteAutomation(repo),
      toggleAutomation: ToggleAutomation(repo),
    );

const _condition = ScheduleConditionEntity(
  conditionType: 'SCHEDULE',
  loops: '1111111',
  time: '18:00',
);

const _action = SceneActionEntity(
  actionType: 'DEVICE_CONTROL',
  entityId: 'device-1',
  executorProperty: {'dpId': 1, 'dpValue': 'on'},
);

void main() {
  group('AutomationBloc', () {
    blocTest<AutomationBloc, AutomationState>(
      'LoadAutomationsEvent emits [Loading, Loaded]',
      build: () => _blocFor(_FakeAutomationRepository(automations: [
        const AutomationSceneEntity(
          id: 'a1',
          name: 'Evening lights',
          sceneType: 'AUTOMATION',
          enabled: true,
          conditions: [_condition],
          conditionLogic: 'AND',
          actions: [_action],
        ),
      ])),
      act: (bloc) => bloc.add(const LoadAutomationsEvent('home-1')),
      expect: () => [
        isA<AutomationLoading>(),
        isA<AutomationLoaded>(),
      ],
    );

    blocTest<AutomationBloc, AutomationState>(
      'CreateAutomationEvent before any load fails with "Home not found" '
      '(guards against the un-seeded bloc the orphaned detail page used to hit)',
      build: () => _blocFor(_FakeAutomationRepository()),
      act: (bloc) => bloc.add(const CreateAutomationEvent(
        name: 'X',
        conditions: [_condition],
        actions: [_action],
      )),
      expect: () => [
        const AutomationError('Home not found'),
      ],
    );

    test(
        'a load seeds the homeId so a subsequent create targets that home',
        () async {
      final repo = _FakeAutomationRepository();
      final bloc = _blocFor(repo);

      bloc.add(const LoadAutomationsEvent('home-42'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(const CreateAutomationEvent(
        name: 'Morning',
        conditions: [_condition],
        actions: [_action],
      ));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(repo.lastCreateHomeId, 'home-42');
      await bloc.close();
    });
  });
}
