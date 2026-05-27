import 'package:equatable/equatable.dart';

class ScheduleConditionEntity extends Equatable {
  final String conditionType; // "SCHEDULE"
  final String timeZoneId; // e.g. "Asia/Ho_Chi_Minh"
  final String loops; // 7-char string MON-SUN, "1"=active "0"=skip
  final String time; // "HH:mm" 24-hour format
  final String? date; // "yyyyMMdd" required when loops="0000000"

  const ScheduleConditionEntity({
    required this.conditionType,
    required this.timeZoneId,
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

  String get displayText => '$time | $displayLoops';

  @override
  List<Object?> get props => [conditionType, timeZoneId, loops, time, date];
}
