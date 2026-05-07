import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:smart_curtain_app/core/error/failure.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/scene_entity.dart';
import 'package:smart_curtain_app/features/scene/domain/usecases/create_scene.dart';
import 'package:smart_curtain_app/features/scene/domain/usecases/delete_scene.dart';
import 'package:smart_curtain_app/features/scene/domain/usecases/get_scenes.dart';
import 'package:smart_curtain_app/features/scene/domain/usecases/toggle_scene.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/scene_bloc.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/scene_event.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/scene_state.dart';

class _MockGetScenes extends Mock implements GetScenes {}

class _MockCreateScene extends Mock implements CreateScene {}

class _MockDeleteScene extends Mock implements DeleteScene {}

class _MockToggleScene extends Mock implements ToggleScene {}

void main() {
  late _MockGetScenes getScenes;
  late _MockCreateScene createScene;
  late _MockDeleteScene deleteScene;
  late _MockToggleScene toggleScene;

  setUp(() {
    getScenes = _MockGetScenes();
    createScene = _MockCreateScene();
    deleteScene = _MockDeleteScene();
    toggleScene = _MockToggleScene();
  });

  SceneBloc buildBloc() => SceneBloc(
        getScenes: getScenes,
        createScene: createScene,
        deleteScene: deleteScene,
        toggleScene: toggleScene,
      );

  final tCreatedAt = DateTime.utc(2026, 5, 7, 8, 30);

  SceneEntity sceneAt({
    required int id,
    bool enabled = true,
  }) =>
      SceneEntity(
        id: id,
        userId: 'user-1',
        name: 'Scene $id',
        deviceToken: 'tok-$id',
        action: 'on',
        time: '08:00',
        daysOfWeek: '1,2,3,4,5',
        enabled: enabled,
        repeatMode: 'daily',
        createdAt: tCreatedAt,
      );

  group('initial state', () {
    test('is SceneInitial', () {
      expect(buildBloc().state, isA<SceneInitial>());
    });
  });

  group('LoadScenesEvent', () {
    blocTest<SceneBloc, SceneState>(
      'emits [SceneLoading, SceneLoaded] on success',
      build: () {
        when(() => getScenes()).thenAnswer(
          (_) async => Right<Failure, List<SceneEntity>>([sceneAt(id: 1)]),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadScenesEvent()),
      expect: () => [
        isA<SceneLoading>(),
        isA<SceneLoaded>().having((s) => s.scenes.length, 'scenes', 1),
      ],
    );

    blocTest<SceneBloc, SceneState>(
      'emits [SceneLoading, SceneError] on failure',
      build: () {
        when(() => getScenes()).thenAnswer(
          (_) async =>
              const Left(ServerFailure('err', message: 'load failed')),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadScenesEvent()),
      expect: () => [
        isA<SceneLoading>(),
        isA<SceneError>().having((s) => s.message, 'message', 'load failed'),
      ],
    );
  });

  group('CreateSceneEvent', () {
    final tEvent = const CreateSceneEvent(
      deviceId: 'dev-1',
      name: 'Morning',
      action: 'on',
      time: '07:00',
      daysOfWeek: '1,2,3,4,5',
      repeatMode: 'daily',
    );

    blocTest<SceneBloc, SceneState>(
      'emits [SceneCreating, SceneCreated] then reloads list',
      build: () {
        when(() => createScene(
              deviceId: any(named: 'deviceId'),
              name: any(named: 'name'),
              action: any(named: 'action'),
              time: any(named: 'time'),
              daysOfWeek: any(named: 'daysOfWeek'),
              repeatMode: any(named: 'repeatMode'),
            )).thenAnswer(
          (_) async => Right<Failure, SceneEntity>(sceneAt(id: 1)),
        );
        when(() => getScenes()).thenAnswer(
          (_) async => Right<Failure, List<SceneEntity>>([sceneAt(id: 1)]),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        isA<SceneCreating>(),
        isA<SceneCreated>(),
        isA<SceneLoading>(),
        isA<SceneLoaded>(),
      ],
      verify: (_) {
        verify(() => getScenes()).called(1);
      },
    );

    blocTest<SceneBloc, SceneState>(
      'emits [SceneCreating, SceneError] on failure and does NOT reload',
      build: () {
        when(() => createScene(
              deviceId: any(named: 'deviceId'),
              name: any(named: 'name'),
              action: any(named: 'action'),
              time: any(named: 'time'),
              daysOfWeek: any(named: 'daysOfWeek'),
              repeatMode: any(named: 'repeatMode'),
            )).thenAnswer(
          (_) async =>
              const Left(ServerFailure('err', message: 'duplicate name')),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        isA<SceneCreating>(),
        isA<SceneError>()
            .having((s) => s.message, 'message', 'duplicate name'),
      ],
      verify: (_) {
        verifyNever(() => getScenes());
      },
    );
  });

  group('DeleteSceneEvent', () {
    blocTest<SceneBloc, SceneState>(
      'removes scene from loaded list on success',
      build: () {
        when(() => deleteScene(1)).thenAnswer(
          (_) async => const Right<Failure, void>(null),
        );
        return buildBloc();
      },
      seed: () => SceneLoaded([sceneAt(id: 1), sceneAt(id: 2)]),
      act: (bloc) => bloc.add(const DeleteSceneEvent(1)),
      expect: () => [
        isA<SceneLoaded>().having(
          (s) => s.scenes.map((e) => e.id).toList(),
          'remaining ids',
          [2],
        ),
      ],
    );

    blocTest<SceneBloc, SceneState>(
      'emits SceneError when delete fails',
      build: () {
        when(() => deleteScene(any())).thenAnswer(
          (_) async => const Left(ServerFailure('err', message: 'denied')),
        );
        return buildBloc();
      },
      seed: () => SceneLoaded([sceneAt(id: 1)]),
      act: (bloc) => bloc.add(const DeleteSceneEvent(1)),
      expect: () => [
        isA<SceneError>().having((s) => s.message, 'message', 'denied'),
      ],
    );
  });

  group('ToggleSceneEvent', () {
    blocTest<SceneBloc, SceneState>(
      'optimistically updates enabled flag on success',
      build: () {
        when(() => toggleScene(1, false)).thenAnswer(
          (_) async => const Right<Failure, void>(null),
        );
        return buildBloc();
      },
      seed: () => SceneLoaded([sceneAt(id: 1, enabled: true)]),
      act: (bloc) => bloc.add(const ToggleSceneEvent(1, false)),
      expect: () => [
        isA<SceneLoaded>().having(
          (s) => s.scenes.first.enabled,
          'enabled',
          false,
        ),
      ],
    );

    blocTest<SceneBloc, SceneState>(
      'reverts by reloading from server when toggle fails',
      build: () {
        when(() => toggleScene(any(), any())).thenAnswer(
          (_) async => const Left(ServerFailure('err', message: 'fail')),
        );
        when(() => getScenes()).thenAnswer(
          (_) async => Right<Failure, List<SceneEntity>>(
            [sceneAt(id: 1, enabled: true)],
          ),
        );
        return buildBloc();
      },
      seed: () => SceneLoaded([sceneAt(id: 1, enabled: true)]),
      act: (bloc) => bloc.add(const ToggleSceneEvent(1, false)),
      expect: () => [
        // optimistic flip
        isA<SceneLoaded>().having(
          (s) => s.scenes.first.enabled,
          'optimistic',
          false,
        ),
        // reload after failure
        isA<SceneLoading>(),
        isA<SceneLoaded>().having(
          (s) => s.scenes.first.enabled,
          'reverted',
          true,
        ),
      ],
    );
  });
}
