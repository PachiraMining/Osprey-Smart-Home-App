// lib/features/device/domain/usecases/delete_device.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/device_repository.dart';

class DeleteDevice {
  final DeviceRepository repository;

  DeleteDevice(this.repository);

  Future<Either<Failure, void>> call(String deviceId) async {
    return await repository.deleteDevice(deviceId);
  }
}
