import '../../domain/entities/smart_home_entity.dart';

class SmartHomeModel extends SmartHomeEntity {
  const SmartHomeModel({
    required super.id,
    required super.name,
  });

  factory SmartHomeModel.fromJson(Map<String, dynamic> json) {
    return SmartHomeModel(
      id: json['id']?['id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
