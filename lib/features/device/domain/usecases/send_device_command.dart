// lib/features/device/domain/usecases/send_device_command.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';

import '../repositories/device_control_repository.dart';

class SendDeviceCommand {
  final DeviceControlRepository repository;

  SendDeviceCommand(this.repository);

  Future<Either<Failure, void>> call(String deviceId, String command) async {
    return await repository.sendCommand(deviceId, command);
  }
}
