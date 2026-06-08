import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/factory_reset_result.dart';
import '../repositories/home_repository.dart';

/// Nút "Hủy liên kết và xóa dữ liệu" — gửi RPC factoryReset tới chip
/// + cascade xóa toàn bộ dữ liệu thiết bị (telemetry, history, MQTT token).
class FactoryResetDevice {
  final HomeRepository repository;
  FactoryResetDevice(this.repository);

  Future<Either<Failure, FactoryResetResult>> call({
    required String homeId,
    required String deviceId,
  }) =>
      repository.factoryResetDevice(homeId: homeId, deviceId: deviceId);
}
