import 'package:equatable/equatable.dart';
import '../../../domain/entities/tap_to_run_scene_entity.dart';

abstract class TapToRunState extends Equatable {
  const TapToRunState();

  @override
  List<Object?> get props => [];
}

class TapToRunInitial extends TapToRunState {}

class TapToRunLoading extends TapToRunState {}

class TapToRunLoaded extends TapToRunState {
  final List<TapToRunSceneEntity> scenes;
  const TapToRunLoaded(this.scenes);

  @override
  List<Object?> get props => [scenes];
}

class TapToRunError extends TapToRunState {
  final String message;
  const TapToRunError(this.message);

  @override
  List<Object?> get props => [message];
}

class TapToRunCreating extends TapToRunState {}

class TapToRunCreated extends TapToRunState {}

class TapToRunExecuting extends TapToRunState {
  final String sceneId;
  final List<TapToRunSceneEntity> scenes;
  const TapToRunExecuting(this.sceneId, this.scenes);

  @override
  List<Object?> get props => [sceneId, scenes];
}

class TapToRunExecuteResult extends TapToRunState {
  final String status; // SUCCESS, PARTIAL, FAILURE
  final String details;
  final List<TapToRunSceneEntity> scenes;

  const TapToRunExecuteResult({
    required this.status,
    required this.details,
    required this.scenes,
  });

  @override
  List<Object?> get props => [status, details, scenes];
}
