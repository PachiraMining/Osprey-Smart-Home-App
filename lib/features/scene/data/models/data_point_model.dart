import '../../domain/entities/data_point_entity.dart';

class DataPointModel extends DataPointEntity {
  const DataPointModel({
    required super.dpId,
    required super.code,
    required super.name,
    required super.dpType,
    required super.mode,
    required super.constraints,
  });

  factory DataPointModel.fromJson(Map<String, dynamic> json) {
    return DataPointModel(
      dpId: json['dpId'] as int,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dpType: json['dpType'] as String? ?? 'STRING',
      mode: json['mode'] as String? ?? 'RO',
      constraints: json['constraints'] as Map<String, dynamic>? ?? {},
    );
  }
}
