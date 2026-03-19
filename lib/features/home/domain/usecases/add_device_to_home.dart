import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/home_repository.dart';

class AddDeviceToHome {
  final HomeRepository repository;
  AddDeviceToHome(this.repository);

  Future<Either<Failure, void>> call({
    required String homeId,
    required String deviceId,
  }) =>
      repository.addDeviceToHome(homeId: homeId, deviceId: deviceId);
}
