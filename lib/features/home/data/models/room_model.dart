import '../../domain/entities/room_entity.dart';

class RoomModel extends RoomEntity {
  const RoomModel({
    required super.id,
    required super.name,
    super.icon,
    super.sortOrder,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id']?['id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    if (icon != null) 'icon': icon,
    'sortOrder': sortOrder,
  };
}
