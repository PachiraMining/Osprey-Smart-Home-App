import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/automation_condition_entity.dart';

void main() {
  test('DeviceStatusConditionEntity mang đúng conditionType', () {
    const c = DeviceStatusConditionEntity(
      entityId: 'dev-1',
      dpCode: 'control',
      operator: '==',
      value: 'open',
      valueType: 'STRING',
    );
    expect(c.conditionType, 'DEVICE_STATUS');
  });

  test('ScheduleConditionEntity vẫn mang conditionType SCHEDULE', () {
    const c = ScheduleConditionEntity(
      conditionType: 'SCHEDULE',
      loops: '1111111',
      time: '17:00',
    );
    expect(c.conditionType, 'SCHEDULE');
    expect(c.isDaily, isTrue);
  });

  test('switch trên sealed vét cạn được cả hai nhánh', () {
    final list = <AutomationConditionEntity>[
      const ScheduleConditionEntity(
          conditionType: 'SCHEDULE', loops: '1111111', time: '08:00'),
      const DeviceStatusConditionEntity(
          entityId: 'd',
          dpCode: 'control',
          operator: '==',
          value: 'open',
          valueType: 'STRING'),
    ];
    final kinds = list.map((c) => switch (c) {
          ScheduleConditionEntity() => 'schedule',
          DeviceStatusConditionEntity() => 'device',
        });
    expect(kinds, ['schedule', 'device']);
  });

  test('displayText của điều kiện thiết bị đọc được', () {
    const c = DeviceStatusConditionEntity(
      entityId: 'dev-1',
      dpCode: 'control',
      operator: '==',
      value: 'open',
      valueType: 'STRING',
      dpName: 'Control',
    );
    expect(c.displayText, 'Control : open');
  });

  test('dpName chỉ để hiển thị, không tham gia so sánh bằng', () {
    const a = DeviceStatusConditionEntity(
      entityId: 'd', dpCode: 'control', operator: '==',
      value: 'open', valueType: 'STRING', dpName: 'Control',
    );
    const b = DeviceStatusConditionEntity(
      entityId: 'd', dpCode: 'control', operator: '==',
      value: 'open', valueType: 'STRING',
    );
    expect(a, equals(b));
  });
}
