import 'dart:developer' as dev;

import '../../domain/entities/automation_condition_entity.dart';

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
    // Chỉ gửi khi cố ý ghi đè; bỏ trống để backend dùng home.timezone.
    if (timeZoneId != null) map['timeZoneId'] = timeZoneId;
    if (date != null) map['date'] = date;
    return map;
  }
}

class DeviceStatusConditionModel extends DeviceStatusConditionEntity {
  const DeviceStatusConditionModel({
    required super.entityId,
    required super.dpCode,
    required super.operator,
    required super.value,
    required super.valueType,
    super.dpName,
  });

  factory DeviceStatusConditionModel.fromJson(Map<String, dynamic> json) {
    return DeviceStatusConditionModel(
      entityId: json['entityId'] as String? ?? '',
      dpCode: json['dpCode'] as String? ?? '',
      operator: json['operator'] as String? ?? '==',
      value: json['value'] as Object? ?? '',
      valueType: json['valueType'] as String? ?? 'STRING',
    );
  }

  Map<String, dynamic> toJson() => {
        'conditionType': conditionType,
        'entityId': entityId,
        'dpCode': dpCode,
        'operator': operator,
        'value': value,
        'valueType': valueType,
      };
}

/// Phân giải một phần tử `conditions[]` từ backend.
///
/// Trả `null` khi không nhận ra `conditionType` — backend có thể thêm loại mới
/// trước khi app kịp cập nhật, ném lỗi ở đây sẽ làm hỏng cả danh sách.
AutomationConditionEntity? automationConditionFromJson(
    Map<String, dynamic> json) {
  final type = json['conditionType'] as String?;
  switch (type) {
    case 'SCHEDULE':
      return ScheduleConditionModel.fromJson(json);
    case 'DEVICE_STATUS':
      return DeviceStatusConditionModel.fromJson(json);
    default:
      dev.log('Bỏ qua điều kiện không nhận ra: $type',
          name: 'automation_condition');
      return null;
  }
}

Map<String, dynamic> automationConditionToJson(AutomationConditionEntity c) =>
    switch (c) {
      ScheduleConditionEntity() => ScheduleConditionModel(
          conditionType: c.conditionType,
          timeZoneId: c.timeZoneId,
          loops: c.loops,
          time: c.time,
          date: c.date,
        ).toJson(),
      DeviceStatusConditionEntity() => DeviceStatusConditionModel(
          entityId: c.entityId,
          dpCode: c.dpCode,
          operator: c.operator,
          value: c.value,
          valueType: c.valueType,
        ).toJson(),
    };
