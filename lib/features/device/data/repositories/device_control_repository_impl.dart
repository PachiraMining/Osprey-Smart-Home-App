// lib/features/device/data/repositories/device_control_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/device_control_repository.dart';
import '../datasources/device_control_data_source.dart';

class DeviceControlRepositoryImpl implements DeviceControlRepository {
  final DeviceControlDataSource dataSource;

  DeviceControlRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, void>> sendCommand(
    String deviceId,
    String command,
  ) async {
    try {
      await dataSource.sendCommand(deviceId, command);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure('Unexpected error: $e', message: ''));
    } on NetworkException catch (e) {
      return Left(
        NetworkFailure(
          'Unexpected error: $e',
          message: 'Không có kết nối internet',
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', message: ''));
    }
  }
}
