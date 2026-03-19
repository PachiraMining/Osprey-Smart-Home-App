import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

class CreateHome {
  final HomeRepository repository;
  CreateHome(this.repository);

  Future<Either<Failure, HomeEntity>> call({
    required String name,
    String? geoName,
    double? latitude,
    double? longitude,
    String? timezone,
  }) =>
      repository.createHome(
        name: name,
        geoName: geoName,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
}
