import 'package:equatable/equatable.dart';

class HomeEntity extends Equatable {
  final String id;
  final String name;
  final String? ownerUserId;
  final String? geoName;
  final double? latitude;
  final double? longitude;
  final String? timezone;

  const HomeEntity({
    required this.id,
    required this.name,
    this.ownerUserId,
    this.geoName,
    this.latitude,
    this.longitude,
    this.timezone,
  });

  @override
  List<Object?> get props => [id, name, ownerUserId, geoName, latitude, longitude, timezone];
}
