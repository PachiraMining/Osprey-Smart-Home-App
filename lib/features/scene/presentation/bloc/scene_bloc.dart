import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/scene_entity.dart';
import '../../domain/usecases/get_scenes.dart';
import '../../domain/usecases/create_scene.dart';
import '../../domain/usecases/delete_scene.dart';
import '../../domain/usecases/toggle_scene.dart';
import 'scene_event.dart';
import 'scene_state.dart';

class SceneBloc extends Bloc<SceneEvent, SceneState> {
  final GetScenes getScenes;
  final CreateScene createScene;
  final DeleteScene deleteScene;
  final ToggleScene toggleScene;

  SceneBloc({
    required this.getScenes,
    required this.createScene,
    required this.deleteScene,
    required this.toggleScene,
  }) : super(SceneInitial()) {
    on<LoadScenesEvent>(_onLoadScenes);
    on<CreateSceneEvent>(_onCreateScene);
    on<DeleteSceneEvent>(_onDeleteScene);
    on<ToggleSceneEvent>(_onToggleScene);
  }

  Future<void> _onLoadScenes(
    LoadScenesEvent event,
    Emitter<SceneState> emit,
  ) async {
    emit(SceneLoading());
    final result = await getScenes();
    result.fold(
      (failure) => emit(SceneError(failure.message)),
      (scenes) => emit(SceneLoaded(scenes)),
    );
  }

  Future<void> _onCreateScene(
    CreateSceneEvent event,
    Emitter<SceneState> emit,
  ) async {
    emit(SceneCreating());
    final result = await createScene(
      deviceId: event.deviceId,
      name: event.name,
      action: event.action,
      time: event.time,
      daysOfWeek: event.daysOfWeek,
      repeatMode: event.repeatMode,
    );
    result.fold(
      (failure) => emit(SceneError(failure.message)),
      (_) {
        emit(SceneCreated());
        add(LoadScenesEvent());
      },
    );
  }

  Future<void> _onDeleteScene(
    DeleteSceneEvent event,
    Emitter<SceneState> emit,
  ) async {
    final List<SceneEntity> currentScenes = state is SceneLoaded
        ? (state as SceneLoaded).scenes
        : [];

    final result = await deleteScene(event.sceneId);
    result.fold(
      (failure) => emit(SceneError(failure.message)),
      (_) {
        final updated = currentScenes
            .where((s) => s.id != event.sceneId)
            .toList();
        emit(SceneLoaded(updated));
      },
    );
  }

  Future<void> _onToggleScene(
    ToggleSceneEvent event,
    Emitter<SceneState> emit,
  ) async {
    // Optimistic update
    if (state is SceneLoaded) {
      final currentScenes = (state as SceneLoaded).scenes;
      final updated = currentScenes.map((s) {
        if (s.id == event.sceneId) {
          return SceneEntity(
            id: s.id,
            userId: s.userId,
            name: s.name,
            deviceToken: s.deviceToken,
            action: s.action,
            time: s.time,
            daysOfWeek: s.daysOfWeek,
            enabled: event.enabled,
            repeatMode: s.repeatMode,
            createdAt: s.createdAt,
          );
        }
        return s;
      }).toList();
      emit(SceneLoaded(updated));
    }

    final result = await toggleScene(event.sceneId, event.enabled);
    result.fold(
      (failure) {
        // Revert on failure - reload from server
        add(LoadScenesEvent());
      },
      (_) {
        // Already updated optimistically
      },
    );
  }
}
