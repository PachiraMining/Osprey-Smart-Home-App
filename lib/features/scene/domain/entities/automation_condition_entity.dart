import 'package:equatable/equatable.dart';

/// Điều kiện kích hoạt của một automation.
///
/// `sealed` để `switch` phải vét cạn: thêm loại điều kiện mới (vd Weather) là
/// compiler chỉ ra MỌI chỗ cần sửa, thay vì để sót tới lúc chạy. Vì `sealed`
/// chỉ cho kế thừa trong cùng library, mọi lớp con phải nằm trong file này.
sealed class AutomationConditionEntity extends Equatable {
  const AutomationConditionEntity();

  String get conditionType;

  /// Dòng phụ đề hiển thị trong thẻ If.
  String get displayText;
}

class ScheduleConditionEntity extends AutomationConditionEntity {
  @override
  final String conditionType; // "SCHEDULE"

  /// Null → backend lấy zone từ home.timezone (nên dùng). Chỉ đặt khi muốn ghi
  /// đè zone cho riêng một scene; giá trị ghi cứng ở đây sẽ THẮNG timezone của
  /// home trong thứ tự ưu tiên của ScheduleCalculator.
  final String? timeZoneId;
  final String loops; // 7 ký tự MON-SUN, "1"=bật "0"=bỏ
  final String time; // "HH:mm" 24h
  final String? date; // "yyyyMMdd", bắt buộc khi loops="0000000"

  const ScheduleConditionEntity({
    required this.conditionType,
    this.timeZoneId,
    required this.loops,
    required this.time,
    this.date,
  });

  bool get isOneTime => loops == '0000000';

  bool get isDaily => loops == '1111111';

  bool get isWeekdays => loops == '0111110';

  bool get isWeekends => loops == '0000011';

  String get _formatDate {
    if (date == null || date!.length != 8) return 'Once';
    final m = int.tryParse(date!.substring(4, 6)) ?? 0;
    final d = int.tryParse(date!.substring(6, 8)) ?? 0;
    return '$m/$d';
  }

  String get displayLoops {
    if (isOneTime) return _formatDate;
    if (isDaily) return 'Every day';
    if (isWeekdays) return 'Mon - Fri';
    if (isWeekends) return 'Sat - Sun';

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final active = <String>[];
    for (var i = 0; i < 7 && i < loops.length; i++) {
      if (loops[i] == '1') active.add(days[i]);
    }
    return active.join(', ');
  }

  @override
  String get displayText => '$time | $displayLoops';

  @override
  List<Object?> get props => [conditionType, timeZoneId, loops, time, date];
}

class DeviceStatusConditionEntity extends AutomationConditionEntity {
  /// UUID thiết bị, phải thuộc cùng home với scene.
  final String entityId;

  /// Mã DP lấy từ GET /api/smarthome/products/{deviceProfileId}/datapoints.
  final String dpCode;

  /// == != > >= < <= — nhóm so sánh số chỉ hợp lệ với valueType NUMBER.
  final String operator;

  /// Giá trị so sánh, đúng kiểu JSON: num, bool hoặc String.
  final Object value;

  /// NUMBER | BOOLEAN | STRING (ENUM dùng STRING).
  final String valueType;

  /// Tên DP hiển thị cho người dùng. Chỉ dùng để vẽ giao diện, KHÔNG gửi lên
  /// backend và KHÔNG tính vào props — hai điều kiện chỉ khác nhãn hiển thị
  /// vẫn là cùng một điều kiện.
  final String? dpName;

  const DeviceStatusConditionEntity({
    required this.entityId,
    required this.dpCode,
    required this.operator,
    required this.value,
    required this.valueType,
    this.dpName,
  });

  @override
  String get conditionType => 'DEVICE_STATUS';

  @override
  String get displayText => '${dpName ?? dpCode} : $value';

  @override
  List<Object?> get props => [entityId, dpCode, operator, value, valueType];
}
