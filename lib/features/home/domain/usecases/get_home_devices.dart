import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/home_device_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeDevices {
  final HomeRepository repository;
  GetHomeDevices(this.repository);

  Future<Either<Failure, List<HomeDeviceEntity>>> call(String homeId) =>
      repository.getHomeDevices(homeId);
}
