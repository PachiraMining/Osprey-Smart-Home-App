import 'package:equatable/equatable.dart';
import 'scene_action_entity.dart';
import 'automation_condition_entity.dart';
import 'effective_time_entity.dart';

class AutomationSceneEntity extends Equatable {
  final String id;
  final String name;
  final String sceneType; // "AUTOMATION"
  final String? icon;
  final bool enabled;
  final List<AutomationConditionEntity> conditions;
  final String conditionLogic; // "AND" or "OR"
  final EffectiveTimeEntity? effectiveTime;
  final List<SceneActionEntity> actions;

  const AutomationSceneEntity({
    required this.id,
    required this.name,
    required this.sceneType,
    this.icon,
    required this.enabled,
    required this.conditions,
    required this.conditionLogic,
    this.effectiveTime,
    required this.actions,
  });

  String get conditionSummary {
    if (conditions.isEmpty) return 'No condition';
    return conditions.first.displayText;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        sceneType,
        icon,
        enabled,
        conditions,
        conditionLogic,
        effectiveTime,
        actions,
      ];
}
