import 'package:equatable/equatable.dart';

class EffectiveTimeEntity extends Equatable {
  final String type; // "ALL_DAY" or "CUSTOM"
  final String? startTime; // "HH:mm" for CUSTOM
  final String? endTime; // "HH:mm" for CUSTOM
  final String? loops; // 7-char string for CUSTOM
  final String timeZoneId;

  const EffectiveTimeEntity({
    required this.type,
    this.startTime,
    this.endTime,
    this.loops,
    required this.timeZoneId,
  });

  bool get isAllDay => type == 'ALL_DAY';

  @override
  List<Object?> get props => [type, startTime, endTime, loops, timeZoneId];
}
