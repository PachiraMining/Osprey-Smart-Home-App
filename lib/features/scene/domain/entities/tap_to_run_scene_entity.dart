import 'package:equatable/equatable.dart';
import 'scene_action_entity.dart';

class TapToRunSceneEntity extends Equatable {
  final String id;
  final String name;
  final String sceneType; // "TAP_TO_RUN"
  final String? icon;
  final bool enabled;
  final List<SceneActionEntity> actions;

  const TapToRunSceneEntity({
    required this.id,
    required this.name,
    required this.sceneType,
    this.icon,
    required this.enabled,
    required this.actions,
  });

  @override
  List<Object?> get props => [id, name, sceneType, icon, enabled, actions];
}
