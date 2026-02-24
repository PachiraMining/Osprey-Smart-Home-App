// lib/features/device/domain/repositories/device_control_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';

abstract class DeviceControlRepository {
  Future<Either<Failure, void>> sendCommand(String deviceId, String command);
}
