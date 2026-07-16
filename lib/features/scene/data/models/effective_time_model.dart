import '../../domain/entities/effective_time_entity.dart';

class EffectiveTimeModel extends EffectiveTimeEntity {
  const EffectiveTimeModel({
    required super.type,
    super.startTime,
    super.endTime,
    super.loops,
    super.timeZoneId,
  });

  factory EffectiveTimeModel.fromJson(Map<String, dynamic> json) {
    return EffectiveTimeModel(
      type: json['type'] as String? ?? 'ALL_DAY',
      startTime: json['start'] as String?,
      endTime: json['end'] as String?,
      loops: json['loops'] as String?,
      timeZoneId: json['timeZoneId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'type': type,
    };
    // Only send when explicitly overriding; otherwise backend uses home.timezone.
    if (timeZoneId != null) map['timeZoneId'] = timeZoneId;
    if (startTime != null) map['start'] = startTime;
    if (endTime != null) map['end'] = endTime;
    if (loops != null) map['loops'] = loops;
    return map;
  }
}
