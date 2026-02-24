// lib/features/device/domain/repositories/device_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/device_entity.dart';

abstract class DeviceRepository {
  Future<Either<Failure, List<DeviceEntity>>> getCustomerDevices();
  Future<Either<Failure, void>> deleteDevice(String deviceId);
}
