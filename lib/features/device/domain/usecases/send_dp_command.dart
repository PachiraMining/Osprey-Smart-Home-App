import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../data/datasources/device_control_data_source.dart';

/// Sends an arbitrary DP write (e.g. Motor Direction dpId 5) that the
/// string-based SendDeviceCommand doesn't cover.
class SendDpCommand {
  final DeviceControlDataSource dataSource;
  SendDpCommand(this.dataSource);

  Future<Either<Failure, void>> call(
      String deviceId, int dpId, dynamic value) async {
    try {
      await dataSource.sendDp(deviceId, dpId, value);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized',
          message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return const Left(ServerFailure('cmd', message: 'Network error'));
    }
  }
}
