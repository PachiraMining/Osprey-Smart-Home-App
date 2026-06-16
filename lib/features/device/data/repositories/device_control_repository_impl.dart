// lib/features/device/data/repositories/device_control_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../control/domain/repositories/transport_router.dart';
import '../../domain/repositories/device_control_repository.dart';

/// Device control delegates to [TransportRouter] để chọn MQTT/RPC vs BLE
/// fallback (spec BLE_CONTROL_FALLBACK §4). Repository chỉ là adapter mỏng.
class DeviceControlRepositoryImpl implements DeviceControlRepository {
  final TransportRouter router;

  DeviceControlRepositoryImpl({required this.router});

  @override
  Future<Either<Failure, void>> sendCommand(
    String deviceId,
    String command,
  ) {
    return router.sendCommand(tbDeviceId: deviceId, command: command);
  }
}
