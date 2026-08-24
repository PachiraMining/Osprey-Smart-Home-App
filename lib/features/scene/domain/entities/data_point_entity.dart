import 'package:equatable/equatable.dart';

class DataPointEntity extends Equatable {
  final int dpId;
  final String code;
  final String name;
  final String dpType; // BOOLEAN, ENUM, VALUE, STRING
  final String mode; // RW, RO, WO
  final Map<String, dynamic> constraints;

  const DataPointEntity({
    required this.dpId,
    required this.code,
    required this.name,
    required this.dpType,
    required this.mode,
    required this.constraints,
  });

  bool get isWritable => mode == 'RW' || mode == 'WO';

  /// Dùng được làm điều kiện automation. DP ghi-only không đọc lại được trạng
  /// thái nên không thể so sánh.
  bool get isReadable => mode == 'RW' || mode == 'RO';

  List<String> get enumOptions {
    final range = constraints['range'];
    final values = constraints['values'];
    if (range is List) return range.cast<String>();
    if (values is List) return values.cast<String>();
    return [];
  }

  @override
  List<Object?> get props => [dpId, code, name, dpType, mode, constraints];
}
