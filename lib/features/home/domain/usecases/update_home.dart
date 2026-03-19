import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

class UpdateHome {
  final HomeRepository repository;
  UpdateHome(this.repository);

  Future<Either<Failure, HomeEntity>> call({
    required String homeId,
    required String name,
    String? geoName,
    double? latitude,
    double? longitude,
    String? timezone,
  }) =>
      repository.updateHome(
        homeId: homeId,
        name: name,
        geoName: geoName,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
}
