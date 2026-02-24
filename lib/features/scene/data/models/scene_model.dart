import '../../domain/entities/scene_entity.dart';

class SceneModel extends SceneEntity {
  const SceneModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.deviceToken,
    required super.action,
    required super.time,
    required super.daysOfWeek,
    required super.enabled,
    required super.repeatMode,
    required super.createdAt,
  });

  factory SceneModel.fromJson(Map<String, dynamic> json) {
    return SceneModel(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      deviceToken: json['device_token'] as String,
      action: json['action'] as String,
      time: json['time'] as String,
      daysOfWeek: json['days_of_week'] as String,
      enabled: json['enabled'] as bool,
      repeatMode: json['repeat_mode'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toCreateJson({
    required String userId,
    required String deviceToken,
  }) {
    return {
      'user_id': userId,
      'name': name,
      'device_token': deviceToken,
      'action': action,
      'time': time,
      'days_of_week': daysOfWeek.split(',').map((e) => int.parse(e.trim())).toList(),
      'enabled': true,
      'repeat_mode': repeatMode,
    };
  }
}
