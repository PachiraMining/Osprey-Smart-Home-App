import 'package:equatable/equatable.dart';
import '../../../domain/entities/scene_action_entity.dart';

abstract class TapToRunEvent extends Equatable {
  const TapToRunEvent();

  @override
  List<Object?> get props => [];
}

class LoadTapToRunScenesEvent extends TapToRunEvent {
  final String homeId;
  const LoadTapToRunScenesEvent(this.homeId);
  @override
  List<Object?> get props => [homeId];
}

class CreateTapToRunSceneEvent extends TapToRunEvent {
  final String name;
  final String? icon;
  final List<SceneActionEntity> actions;

  const CreateTapToRunSceneEvent({
    required this.name,
    this.icon,
    required this.actions,
  });

  @override
  List<Object?> get props => [name, icon, actions];
}

class UpdateTapToRunSceneEvent extends TapToRunEvent {
  final String sceneId;
  final String name;
  final String? icon;
  final List<SceneActionEntity> actions;

  const UpdateTapToRunSceneEvent({
    required this.sceneId,
    required this.name,
    this.icon,
    required this.actions,
  });

  @override
  List<Object?> get props => [sceneId, name, icon, actions];
}

class DeleteTapToRunSceneEvent extends TapToRunEvent {
  final String sceneId;
  const DeleteTapToRunSceneEvent(this.sceneId);

  @override
  List<Object?> get props => [sceneId];
}

class ExecuteTapToRunSceneEvent extends TapToRunEvent {
  final String sceneId;
  const ExecuteTapToRunSceneEvent(this.sceneId);

  @override
  List<Object?> get props => [sceneId];
}

class ToggleTapToRunSceneEvent extends TapToRunEvent {
  final String sceneId;
  final bool enabled;
  const ToggleTapToRunSceneEvent(this.sceneId, this.enabled);

  @override
  List<Object?> get props => [sceneId, enabled];
}
