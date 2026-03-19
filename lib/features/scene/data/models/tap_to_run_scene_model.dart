import '../../domain/entities/tap_to_run_scene_entity.dart';
import 'scene_action_model.dart';

class TapToRunSceneModel extends TapToRunSceneEntity {
  const TapToRunSceneModel({
    required super.id,
    required super.name,
    required super.sceneType,
    super.icon,
    required super.enabled,
    required super.actions,
  });

  factory TapToRunSceneModel.fromJson(Map<String, dynamic> json) {
    final actionsList = json['actions'] as List<dynamic>? ?? [];
    return TapToRunSceneModel(
      id: json['id'] is Map ? json['id']['id'] : (json['id']?.toString() ?? ''),
      name: json['name'] ?? '',
      sceneType: json['sceneType'] ?? 'TAP_TO_RUN',
      icon: json['icon'] as String?,
      enabled: json['enabled'] ?? true,
      actions: actionsList
          .map((a) => SceneActionModel.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'sceneType': sceneType,
      if (icon != null) 'icon': icon,
      'actions': actions
          .map((a) => (a as SceneActionModel).toJson())
          .toList(),
    };
  }
}
