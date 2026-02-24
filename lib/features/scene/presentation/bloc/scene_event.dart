import 'package:equatable/equatable.dart';

abstract class SceneEvent extends Equatable {
  const SceneEvent();

  @override
  List<Object?> get props => [];
}

class LoadScenesEvent extends SceneEvent {}

class CreateSceneEvent extends SceneEvent {
  final String deviceId;
  final String name;
  final String action;
  final String time;
  final String daysOfWeek;
  final String repeatMode;

  const CreateSceneEvent({
    required this.deviceId,
    required this.name,
    required this.action,
    required this.time,
    required this.daysOfWeek,
    required this.repeatMode,
  });

  @override
  List<Object?> get props => [deviceId, name, action, time, daysOfWeek, repeatMode];
}

class DeleteSceneEvent extends SceneEvent {
  final int sceneId;

  const DeleteSceneEvent(this.sceneId);

  @override
  List<Object?> get props => [sceneId];
}

class ToggleSceneEvent extends SceneEvent {
  final int sceneId;
  final bool enabled;

  const ToggleSceneEvent(this.sceneId, this.enabled);

  @override
  List<Object?> get props => [sceneId, enabled];
}
