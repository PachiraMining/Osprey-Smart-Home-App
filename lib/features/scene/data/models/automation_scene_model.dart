import '../../domain/entities/automation_condition_entity.dart';
import '../../domain/entities/automation_scene_entity.dart';
import 'scene_action_model.dart';
import 'automation_condition_model.dart';
import 'effective_time_model.dart';

class AutomationSceneModel extends AutomationSceneEntity {
  const AutomationSceneModel({
    required super.id,
    required super.name,
    required super.sceneType,
    super.icon,
    required super.enabled,
    required super.conditions,
    required super.conditionLogic,
    super.effectiveTime,
    required super.actions,
  });

  factory AutomationSceneModel.fromJson(Map<String, dynamic> json) {
    final rawConditions = json['conditions'];
    final conditionsList = rawConditions is List ? rawConditions : <dynamic>[];
    final rawActions = json['actions'];
    final actionsList = rawActions is List ? rawActions : <dynamic>[];

    return AutomationSceneModel(
      id: json['id'] is Map
          ? json['id']['id'] as String
          : (json['id']?.toString() ?? ''),
      name: json['name'] as String? ?? '',
      sceneType: json['sceneType'] as String? ?? 'AUTOMATION',
      icon: json['icon'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      conditions: conditionsList
          .whereType<Map<String, dynamic>>()
          .map(automationConditionFromJson)
          .whereType<AutomationConditionEntity>()
          .toList(),
      conditionLogic: json['conditionLogic'] as String? ?? 'AND',
      effectiveTime: json['effectiveTime'] is Map<String, dynamic>
          ? EffectiveTimeModel.fromJson(
              json['effectiveTime'] as Map<String, dynamic>)
          : null,
      actions: actionsList
          .whereType<Map<String, dynamic>>()
          .map((a) => SceneActionModel.fromJson(a))
          .toList(),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'sceneType': 'AUTOMATION',
      if (icon != null) 'icon': icon,
      'conditions': conditions.map(automationConditionToJson).toList(),
      'conditionLogic': conditionLogic,
      if (effectiveTime != null)
        'effectiveTime': (effectiveTime as EffectiveTimeModel).toJson(),
      'actions':
          actions.map((a) => (a as SceneActionModel).toJson()).toList(),
    };
  }

  Map<String, dynamic> toUpdateJson({required bool enabled}) {
    final json = toCreateJson();
    json['enabled'] = enabled;
    return json;
  }
}
