import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/home_repository.dart';

class RemoveDeviceFromHome {
  final HomeRepository repository;
  RemoveDeviceFromHome(this.repository);

  Future<Either<Failure, void>> call({
    required String homeId,
    required String deviceId,
  }) =>
      repository.removeDeviceFromHome(homeId: homeId, deviceId: deviceId);
}
