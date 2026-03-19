import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/home_repository.dart';

class UpdateHomeDevice {
  final HomeRepository repository;
  UpdateHomeDevice(this.repository);

  Future<Either<Failure, void>> call({
    required String homeId,
    required String deviceId,
    String? roomId,
    String? deviceName,
    int? sortOrder,
  }) =>
      repository.updateHomeDevice(
        homeId: homeId,
        deviceId: deviceId,
        roomId: roomId,
        deviceName: deviceName,
        sortOrder: sortOrder,
      );
}
