import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../data/datasources/device_control_data_source.dart';

/// Reads live device status → map of DP `code` → value.
class GetDeviceStatus {
  final DeviceControlDataSource dataSource;
  GetDeviceStatus(this.dataSource);

  Future<Either<Failure, Map<String, dynamic>>> call(String deviceId) async {
    try {
      return Right(await dataSource.getStatus(deviceId));
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized',
          message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return const Left(ServerFailure('status', message: 'Network error'));
    }
  }
}
