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
      // The backend stores actions as a free-form JSON array, so the display
      // name/function we send round-trip back on reload (instead of showing the
      // generic 'Device' fallback).
      deviceName: json['deviceName'] as String?,
      functionName: json['functionName'] as String?,
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
    // Persisted so the detail page shows the real device/function after reload.
    if (deviceName != null) {
      map['deviceName'] = deviceName;
    }
    if (functionName != null) {
      map['functionName'] = functionName;
    }
    return map;
  }
}
