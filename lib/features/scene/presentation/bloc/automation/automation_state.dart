import 'package:equatable/equatable.dart';
import '../../../domain/entities/automation_scene_entity.dart';

abstract class AutomationState extends Equatable {
  const AutomationState();

  @override
  List<Object?> get props => [];
}

class AutomationInitial extends AutomationState {}

class AutomationLoading extends AutomationState {}

class AutomationLoaded extends AutomationState {
  final List<AutomationSceneEntity> automations;
  const AutomationLoaded(this.automations);

  @override
  List<Object?> get props => [automations];
}

class AutomationError extends AutomationState {
  final String message;
  const AutomationError(this.message);

  @override
  List<Object?> get props => [message];
}

class AutomationCreating extends AutomationState {}

class AutomationCreated extends AutomationState {}
