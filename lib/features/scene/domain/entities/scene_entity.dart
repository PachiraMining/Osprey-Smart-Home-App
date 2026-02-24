import 'package:equatable/equatable.dart';

class SceneEntity extends Equatable {
  final int id;
  final String userId;
  final String name;
  final String deviceToken;
  final String action; // "on" | "off"
  final String time; // "HH:mm"
  final String daysOfWeek; // "1,2,3,4,5"
  final bool enabled;
  final String repeatMode; // "once" | "daily" | "weekly"
  final DateTime createdAt;

  const SceneEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.deviceToken,
    required this.action,
    required this.time,
    required this.daysOfWeek,
    required this.enabled,
    required this.repeatMode,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    deviceToken,
    action,
    time,
    daysOfWeek,
    enabled,
    repeatMode,
    createdAt,
  ];
}
