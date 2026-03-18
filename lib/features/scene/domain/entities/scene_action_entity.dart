import 'package:equatable/equatable.dart';

class SceneActionEntity extends Equatable {
  final String actionType; // DEVICE_CONTROL, DELAY, SCENE_RUN
  final String? entityId; // device UUID or scene UUID
  final Map<String, dynamic>? executorProperty;

  // Display-only fields (not sent to API, used in UI)
  final String? deviceName;
  final String? functionName;

  const SceneActionEntity({
    required this.actionType,
    this.entityId,
    this.executorProperty,
    this.deviceName,
    this.functionName,
  });

  @override
  List<Object?> get props => [actionType, entityId, executorProperty];
}
