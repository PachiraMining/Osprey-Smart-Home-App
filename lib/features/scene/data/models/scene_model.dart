import '../../domain/entities/scene_entity.dart';

class SceneModel extends SceneEntity {
  const SceneModel({
    required super.id,
    required super.name,
    required super.enabled,
    super.icon,
    required super.conditions,
    required super.actions,
    required super.createdAt,
  });

  factory SceneModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is Map ? rawId['id']?.toString() ?? '' : rawId?.toString() ?? '';

    final rawConditions = json['conditions'];
    final List<SceneCondition> conditions;
    if (rawConditions is List) {
      conditions = rawConditions
          .map((c) => _parseCondition(c as Map<String, dynamic>))
          .toList();
    } else {
      conditions = [];
    }

    final rawActions = json['actions'];
    final List<SceneAction> actions;
    if (rawActions is List) {
      actions = rawActions
          .map((a) => _parseAction(a as Map<String, dynamic>))
          .toList();
    } else {
      actions = [];
    }

    return SceneModel(
      id: id,
      name: (json['name'] ?? '') as String,
      enabled: json['enabled'] as bool? ?? true,
      icon: json['icon'] as String?,
      conditions: conditions,
      actions: actions,
      createdAt: json['createdTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdTime'] as int)
          : DateTime.now(),
    );
  }

  static SceneCondition _parseCondition(Map<String, dynamic> json) {
    return SceneCondition(
      conditionType: json['conditionType']?.toString() ?? 'SCHEDULE',
      date: json['date'] as String?,
      time: json['time'] as String?,
      loops: json['loops'] as String?,
      timeZoneId: json['timeZoneId'] as String?,
    );
  }

  static SceneAction _parseAction(Map<String, dynamic> json) {
    final exec = json['executorProperty'] as Map<String, dynamic>?;
    final actionType = json['actionType']?.toString() ?? '';

    if (actionType == 'DELAY') {
      return SceneAction(
        actionType: actionType,
        delayMinutes: exec?['minutes'] as int?,
        delaySeconds: exec?['seconds'] as int?,
      );
    }

    return SceneAction(
      entityId: json['entityId']?.toString(),
      actionType: actionType,
      dpId: exec?['dpId'] as int?,
      dpValue: exec?['dpValue']?.toString(),
    );
  }
}
