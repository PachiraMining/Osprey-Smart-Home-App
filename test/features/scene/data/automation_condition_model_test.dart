import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/scene/data/models/automation_condition_model.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/automation_condition_entity.dart';

void main() {
  test('phân giải điều kiện DEVICE_STATUS', () {
    final c = automationConditionFromJson({
      'conditionType': 'DEVICE_STATUS',
      'entityId': 'dev-1',
      'dpCode': 'control',
      'operator': '==',
      'value': 'open',
      'valueType': 'STRING',
    });
    expect(c, isA<DeviceStatusConditionEntity>());
    final d = c! as DeviceStatusConditionEntity;
    expect(d.entityId, 'dev-1');
    expect(d.value, 'open');
  });

  test('phân giải điều kiện SCHEDULE', () {
    final c = automationConditionFromJson({
      'conditionType': 'SCHEDULE',
      'loops': '1111111',
      'time': '17:00',
    });
    expect(c, isA<ScheduleConditionEntity>());
  });

  test('conditionType lạ trả null chứ KHÔNG ném lỗi', () {
    // Backend có thể thêm loại mới (vd WEATHER) trước khi app kịp cập nhật.
    // Ném lỗi ở đây sẽ làm hỏng cả danh sách automation.
    expect(
      automationConditionFromJson({'conditionType': 'WEATHER', 'city': 'x'}),
      isNull,
    );
  });

  test('giữ nguyên kiểu số khi round-trip', () {
    final json = {
      'conditionType': 'DEVICE_STATUS',
      'entityId': 'dev-1',
      'dpCode': 'temp',
      'operator': '>',
      'value': 30,
      'valueType': 'NUMBER',
    };
    final back = automationConditionToJson(automationConditionFromJson(json)!);
    expect(back['value'], 30);
    expect(back['value'], isA<int>());
    expect(back['valueType'], 'NUMBER');
    expect(back['operator'], '>');
  });

  test('giữ nguyên kiểu bool khi round-trip', () {
    final json = {
      'conditionType': 'DEVICE_STATUS',
      'entityId': 'dev-1',
      'dpCode': 'switch',
      'operator': '==',
      'value': true,
      'valueType': 'BOOLEAN',
    };
    final back = automationConditionToJson(automationConditionFromJson(json)!);
    expect(back['value'], isTrue);
    expect(back['value'], isA<bool>());
  });

  test('toJson KHÔNG gửi dpName lên backend', () {
    const c = DeviceStatusConditionEntity(
      entityId: 'd',
      dpCode: 'control',
      operator: '==',
      value: 'open',
      valueType: 'STRING',
      dpName: 'Control',
    );
    expect(automationConditionToJson(c).containsKey('dpName'), isFalse);
  });

  test('điều kiện lịch KHÔNG gửi timeZoneId khi để trống', () {
    const c = ScheduleConditionEntity(
      conditionType: 'SCHEDULE',
      loops: '1111111',
      time: '17:00',
    );
    expect(automationConditionToJson(c).containsKey('timeZoneId'), isFalse);
  });

  test('điều kiện lịch round-trip giữ nguyên date của lịch một lần', () {
    const c = ScheduleConditionEntity(
      conditionType: 'SCHEDULE',
      loops: '0000000',
      time: '08:30',
      date: '20260807',
    );
    final back = automationConditionFromJson(automationConditionToJson(c))!
        as ScheduleConditionEntity;
    expect(back.date, '20260807');
    expect(back.isOneTime, isTrue);
  });
}
