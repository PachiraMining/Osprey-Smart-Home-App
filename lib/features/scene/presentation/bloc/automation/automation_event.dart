import 'package:equatable/equatable.dart';
import '../../../domain/entities/scene_action_entity.dart';
import '../../../domain/entities/automation_condition_entity.dart';
import '../../../domain/entities/effective_time_entity.dart';

abstract class AutomationEvent extends Equatable {
  const AutomationEvent();

  @override
  List<Object?> get props => [];
}

class LoadAutomationsEvent extends AutomationEvent {
  final String homeId;
  const LoadAutomationsEvent(this.homeId);

  @override
  List<Object?> get props => [homeId];
}

class CreateAutomationEvent extends AutomationEvent {
  final String name;
  final String? icon;
  final List<AutomationConditionEntity> conditions;
  final String conditionLogic;
  final EffectiveTimeEntity? effectiveTime;
  final List<SceneActionEntity> actions;

  const CreateAutomationEvent({
    required this.name,
    this.icon,
    required this.conditions,
    this.conditionLogic = 'AND',
    this.effectiveTime,
    required this.actions,
  });

  @override
  List<Object?> get props =>
      [name, icon, conditions, conditionLogic, effectiveTime, actions];
}

class UpdateAutomationEvent extends AutomationEvent {
  final String sceneId;
  final String name;
  final String? icon;
  final bool enabled;
  final List<AutomationConditionEntity> conditions;
  final String conditionLogic;
  final EffectiveTimeEntity? effectiveTime;
  final List<SceneActionEntity> actions;

  const UpdateAutomationEvent({
    required this.sceneId,
    required this.name,
    this.icon,
    required this.enabled,
    required this.conditions,
    this.conditionLogic = 'AND',
    this.effectiveTime,
    required this.actions,
  });

  @override
  List<Object?> get props => [
        sceneId,
        name,
        icon,
        enabled,
        conditions,
        conditionLogic,
        effectiveTime,
        actions,
      ];
}

class DeleteAutomationEvent extends AutomationEvent {
  final String sceneId;
  const DeleteAutomationEvent(this.sceneId);

  @override
  List<Object?> get props => [sceneId];
}

class ToggleAutomationEvent extends AutomationEvent {
  final String sceneId;
  final bool enabled;
  const ToggleAutomationEvent(this.sceneId, this.enabled);

  @override
  List<Object?> get props => [sceneId, enabled];
}
