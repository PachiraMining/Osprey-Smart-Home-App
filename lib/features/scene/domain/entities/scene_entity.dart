import 'package:equatable/equatable.dart';

class SceneEntity extends Equatable {
  final String id;
  final String name;
  final bool enabled;
  final String? icon;
  final List<SceneCondition> conditions;
  final List<SceneAction> actions;
  final DateTime createdAt;

  const SceneEntity({
    required this.id,
    required this.name,
    required this.enabled,
    this.icon,
    required this.conditions,
    required this.actions,
    required this.createdAt,
  });

  String get scheduleTime {
    final cond = conditions.firstOrNull;
    return cond?.time ?? '';
  }

  String get scheduleDate {
    final cond = conditions.firstOrNull;
    return cond?.date ?? '';
  }

  String get loops {
    final cond = conditions.firstOrNull;
    return cond?.loops ?? '0000000';
  }

  String get repeatDisplay {
    final l = loops;
    if (l == '1111111') return 'Every day';
    if (l == '1111100') return 'Mon - Fri';
    if (l == '0000011') return 'Weekend';
    if (l == '0000000') return 'Once';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final active = <String>[];
    for (int i = 0; i < l.length && i < 7; i++) {
      if (l[i] == '1') active.add(days[i]);
    }
    return active.isEmpty ? 'Once' : active.join(', ');
  }

  String get actionSummary {
    if (actions.isEmpty) return '';
    final first = actions.first;
    if (first.actionType == 'DEVICE_CONTROL') {
      return first.dpValue ?? '';
    }
    return first.actionType;
  }

  @override
  List<Object?> get props => [id, name, enabled, conditions, actions, createdAt];
}

class SceneCondition extends Equatable {
  final String conditionType;
  final String? date;
  final String? time;
  final String? loops;
  final String? timeZoneId;

  const SceneCondition({
    required this.conditionType,
    this.date,
    this.time,
    this.loops,
    this.timeZoneId,
  });

  @override
  List<Object?> get props => [conditionType, date, time, loops, timeZoneId];
}

class SceneAction extends Equatable {
  final String? entityId;
  final String actionType;
  final int? dpId;
  final String? dpValue;
  final int? delayMinutes;
  final int? delaySeconds;

  const SceneAction({
    this.entityId,
    required this.actionType,
    this.dpId,
    this.dpValue,
    this.delayMinutes,
    this.delaySeconds,
  });

  @override
  List<Object?> get props => [entityId, actionType, dpId, dpValue];
}
