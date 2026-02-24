// lib/features/device/domain/usecases/get_customer_devices.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';

class GetCustomerDevices {
  final DeviceRepository repository;

  GetCustomerDevices(this.repository);

  Future<Either<Failure, List<DeviceEntity>>> call() async {
    return await repository.getCustomerDevices();
  }
}
