import '../../domain/entities/home_entity.dart';

class HomeModel extends HomeEntity {
  const HomeModel({
    required super.id,
    required super.name,
    super.ownerUserId,
    super.geoName,
    super.latitude,
    super.longitude,
    super.timezone,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      id: json['id']?['id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      ownerUserId: json['ownerUserId']?['id'],
      geoName: json['geoName'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      timezone: json['timezone'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    if (geoName != null) 'geoName': geoName,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (timezone != null) 'timezone': timezone,
  };
}
