import 'package:equatable/equatable.dart';
import '../../domain/entities/scene_entity.dart';

abstract class SceneState extends Equatable {
  const SceneState();

  @override
  List<Object?> get props => [];
}

class SceneInitial extends SceneState {}

class SceneLoading extends SceneState {}

class SceneLoaded extends SceneState {
  final List<SceneEntity> scenes;

  const SceneLoaded(this.scenes);

  @override
  List<Object?> get props => [scenes];
}

class SceneError extends SceneState {
  final String message;

  const SceneError(this.message);

  @override
  List<Object?> get props => [message];
}

class SceneCreating extends SceneState {}

class SceneCreated extends SceneState {}
