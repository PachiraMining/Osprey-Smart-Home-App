import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/tap_to_run_scene_entity.dart';
import '../../../domain/usecases/get_tap_to_run_scenes.dart';
import '../../../domain/usecases/create_tap_to_run_scene.dart';
import '../../../domain/usecases/update_tap_to_run_scene.dart';
import '../../../domain/usecases/delete_tap_to_run_scene.dart';
import '../../../domain/usecases/execute_tap_to_run_scene.dart';
import 'tap_to_run_event.dart';
import 'tap_to_run_state.dart';

class TapToRunBloc extends Bloc<TapToRunEvent, TapToRunState> {
  final GetTapToRunScenes getTapToRunScenes;
  final CreateTapToRunScene createTapToRunScene;
  final UpdateTapToRunScene updateTapToRunScene;
  final DeleteTapToRunScene deleteTapToRunScene;
  final ExecuteTapToRunScene executeTapToRunScene;

  String? _homeId;

  TapToRunBloc({
    required this.getTapToRunScenes,
    required this.createTapToRunScene,
    required this.updateTapToRunScene,
    required this.deleteTapToRunScene,
    required this.executeTapToRunScene,
  }) : super(TapToRunInitial()) {
    on<LoadTapToRunScenesEvent>(_onLoadScenes);
    on<CreateTapToRunSceneEvent>(_onCreateScene);
    on<UpdateTapToRunSceneEvent>(_onUpdateScene);
    on<DeleteTapToRunSceneEvent>(_onDeleteScene);
    on<ExecuteTapToRunSceneEvent>(_onExecuteScene);
    on<ToggleTapToRunSceneEvent>(_onToggleScene);
  }

  Future<void> _onLoadScenes(
    LoadTapToRunScenesEvent event,
    Emitter<TapToRunState> emit,
  ) async {
    _homeId = event.homeId;
    emit(TapToRunLoading());
    final result = await getTapToRunScenes(event.homeId);
    result.fold(
      (failure) => emit(TapToRunError(failure.message)),
      (scenes) => emit(TapToRunLoaded(scenes)),
    );
  }

  Future<void> _onCreateScene(
    CreateTapToRunSceneEvent event,
    Emitter<TapToRunState> emit,
  ) async {
    if (_homeId == null) {
      emit(const TapToRunError('Không tìm thấy Home'));
      return;
    }
    emit(TapToRunCreating());
    final result = await createTapToRunScene(
      homeId: _homeId!,
      name: event.name,
      icon: event.icon,
      actions: event.actions,
    );
    result.fold(
      (failure) => emit(TapToRunError(failure.message)),
      (_) {
        emit(TapToRunCreated());
        add(LoadTapToRunScenesEvent(_homeId!));
      },
    );
  }

  Future<void> _onUpdateScene(
    UpdateTapToRunSceneEvent event,
    Emitter<TapToRunState> emit,
  ) async {
    emit(TapToRunCreating());
    final result = await updateTapToRunScene(
      sceneId: event.sceneId,
      name: event.name,
      icon: event.icon,
      actions: event.actions,
    );
    result.fold(
      (failure) => emit(TapToRunError(failure.message)),
      (_) {
        emit(TapToRunCreated());
        if (_homeId != null) add(LoadTapToRunScenesEvent(_homeId!));
      },
    );
  }

  Future<void> _onDeleteScene(
    DeleteTapToRunSceneEvent event,
    Emitter<TapToRunState> emit,
  ) async {
    final currentScenes = state is TapToRunLoaded
        ? (state as TapToRunLoaded).scenes
        : <TapToRunSceneEntity>[];

    final updated = currentScenes.where((s) => s.id != event.sceneId).toList();
    emit(TapToRunLoaded(updated));

    final result = await deleteTapToRunScene(event.sceneId);
    result.fold(
      (failure) => emit(TapToRunLoaded(currentScenes)),
      (_) {},
    );
  }

  Future<void> _onExecuteScene(
    ExecuteTapToRunSceneEvent event,
    Emitter<TapToRunState> emit,
  ) async {
    final currentScenes = state is TapToRunLoaded
        ? (state as TapToRunLoaded).scenes
        : state is TapToRunExecuting
            ? (state as TapToRunExecuting).scenes
            : <TapToRunSceneEntity>[];

    emit(TapToRunExecuting(event.sceneId, currentScenes));

    final result = await executeTapToRunScene(event.sceneId);
    result.fold(
      (failure) => emit(TapToRunLoaded(currentScenes)),
      (data) {
        final status = data['status'] as String? ?? 'FAILURE';
        final details = (data['executionDetails'] as Map<String, dynamic>?)?['details'] as String? ?? '';
        emit(TapToRunExecuteResult(
          status: status,
          details: details,
          scenes: currentScenes,
        ));
      },
    );
  }

  Future<void> _onToggleScene(
    ToggleTapToRunSceneEvent event,
    Emitter<TapToRunState> emit,
  ) async {
    if (state is TapToRunLoaded) {
      final currentScenes = (state as TapToRunLoaded).scenes;
      final updated = currentScenes.map((s) {
        if (s.id == event.sceneId) {
          return TapToRunSceneEntity(
            id: s.id,
            name: s.name,
            sceneType: s.sceneType,
            icon: s.icon,
            enabled: event.enabled,
            actions: s.actions,
          );
        }
        return s;
      }).toList();
      emit(TapToRunLoaded(updated));
    }
  }
}
