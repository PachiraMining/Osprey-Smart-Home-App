// lib/features/device/data/repositories/device_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/device_remote_data_source.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource remoteDataSource;

  DeviceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<DeviceEntity>>> getCustomerDevices() async {
    try {
      final devices = await remoteDataSource.getCustomerDevices();
      return Right(devices);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: ''));
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

  @override
  Future<Either<Failure, void>> deleteDevice(String deviceId) async {
    try {
      await remoteDataSource.deleteDevice(deviceId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: ''));
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
