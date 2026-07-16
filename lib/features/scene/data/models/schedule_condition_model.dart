import '../../domain/entities/schedule_condition_entity.dart';

class ScheduleConditionModel extends ScheduleConditionEntity {
  const ScheduleConditionModel({
    required super.conditionType,
    super.timeZoneId,
    required super.loops,
    required super.time,
    super.date,
  });

  factory ScheduleConditionModel.fromJson(Map<String, dynamic> json) {
    return ScheduleConditionModel(
      conditionType: json['conditionType'] as String? ?? 'SCHEDULE',
      timeZoneId: json['timeZoneId'] as String?,
      loops: json['loops'] as String? ?? '0000000',
      time: json['time'] as String? ?? '00:00',
      date: json['date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'conditionType': conditionType,
      'loops': loops,
      'time': time,
    };
    // Only send when explicitly overriding; otherwise the backend uses
    // home.timezone.
    if (timeZoneId != null) {
      map['timeZoneId'] = timeZoneId;
    }
    if (date != null) {
      map['date'] = date;
    }
    return map;
  }
}
