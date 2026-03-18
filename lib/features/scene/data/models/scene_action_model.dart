import '../../domain/entities/scene_action_entity.dart';

class SceneActionModel extends SceneActionEntity {
  const SceneActionModel({
    required super.actionType,
    super.entityId,
    super.executorProperty,
    super.deviceName,
    super.functionName,
  });

  factory SceneActionModel.fromJson(Map<String, dynamic> json) {
    return SceneActionModel(
      actionType: json['actionType'] as String,
      entityId: json['entityId'] as String?,
      executorProperty: json['executorProperty'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'actionType': actionType,
    };
    if (entityId != null) {
      map['entityId'] = entityId;
    }
    if (executorProperty != null) {
      map['executorProperty'] = executorProperty;
    }
    return map;
  }
}
