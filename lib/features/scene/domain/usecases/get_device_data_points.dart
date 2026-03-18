import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/data_point_entity.dart';
import '../repositories/tap_to_run_repository.dart';

class GetDeviceDataPoints {
  final TapToRunRepository repository;
  GetDeviceDataPoints(this.repository);

  Future<Either<Failure, List<DataPointEntity>>> call(String deviceProfileId) async {
    return await repository.getDeviceDataPoints(deviceProfileId);
  }
}
