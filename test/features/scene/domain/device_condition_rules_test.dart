import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/data_point_entity.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/automation/device_condition_rules.dart';

void main() {
  DataPointEntity dp(String mode,
          {String type = 'ENUM', String code = 'control'}) =>
      DataPointEntity(
        dpId: 1,
        code: code,
        name: 'Control',
        dpType: type,
        mode: mode,
        constraints: const {},
      );

  test('DP ghi-only không dùng làm điều kiện được', () {
    expect(dp('WO').isReadable, isFalse);
  });

  test('DP đọc-ghi và chỉ-đọc đều dùng được', () {
    expect(dp('RW').isReadable, isTrue);
    expect(dp('RO').isReadable, isTrue);
  });

  test('danh sách chọn loại bỏ DP ghi-only', () {
    final all = [dp('RW', code: 'a'), dp('WO', code: 'b'), dp('RO', code: 'c')];
    expect(conditionDataPoints(all).map((d) => d.code), ['a', 'c']);
  });

  test('chỉ DP số mới có toán tử so sánh lớn/nhỏ', () {
    expect(operatorsFor('VALUE'), ['==', '!=', '>', '>=', '<', '<=']);
    expect(operatorsFor('ENUM'), ['==', '!=']);
    expect(operatorsFor('STRING'), ['==', '!=']);
    // Với toggle, `!= true` trùng nghĩa `== false` — để cả hai chỉ tổ rối.
    expect(operatorsFor('BOOLEAN'), ['==']);
  });

  test('valueType suy từ dpType, ENUM đi đường STRING', () {
    expect(valueTypeFor('VALUE'), 'NUMBER');
    expect(valueTypeFor('BOOLEAN'), 'BOOLEAN');
    expect(valueTypeFor('ENUM'), 'STRING');
    expect(valueTypeFor('STRING'), 'STRING');
  });

  test('toán tử mặc định luôn nằm trong danh sách cho phép', () {
    for (final t in ['VALUE', 'BOOLEAN', 'ENUM', 'STRING']) {
      expect(operatorsFor(t), contains(defaultOperatorFor(t)));
    }
  });
}
