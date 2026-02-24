import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/scene_entity.dart';
import '../../domain/repositories/scene_repository.dart';
import '../datasources/scene_remote_datasource.dart';

class SceneRepositoryImpl implements SceneRepository {
  final SceneRemoteDataSource remoteDataSource;
  final String Function() getCustomerId;

  SceneRepositoryImpl({
    required this.remoteDataSource,
    required this.getCustomerId,
  });

  @override
  Future<Either<Failure, List<SceneEntity>>> getScenes() async {
    try {
      final userId = getCustomerId();
      if (userId.isEmpty) {
        return const Left(
          ServerFailure('CustomerId not found', message: 'Vui long dang nhap lai'),
        );
      }
      final scenes = await remoteDataSource.getScenes(userId);
      return Right(scenes);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } on NetworkException {
      return const Left(
        NetworkFailure('Network error', message: 'Khong co ket noi internet'),
      );
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Loi khong xac dinh'));
    }
  }

  @override
  Future<Either<Failure, SceneEntity>> createScene({
    required String deviceId,
    required String name,
    required String action,
    required String time,
    required String daysOfWeek,
    required String repeatMode,
  }) async {
    try {
      final userId = getCustomerId();
      if (userId.isEmpty) {
        return const Left(
          ServerFailure('CustomerId not found', message: 'Vui long dang nhap lai'),
        );
      }

      // Step 1: Get device token from ThingsBoard
      final deviceToken = await remoteDataSource.getDeviceToken(deviceId);

      // Step 2: Create scene on scheduler backend
      final daysOfWeekList = daysOfWeek.split(',').map((e) => int.parse(e.trim())).toList();
      final data = {
        'user_id': userId,
        'name': name,
        'device_token': deviceToken,
        'action': action,
        'time': time,
        'days_of_week': daysOfWeekList,
        'enabled': true,
        'repeat_mode': repeatMode,
      };

      final scene = await remoteDataSource.createScene(data);
      return Right(scene);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } on UnauthorizedException {
      return const Left(
        UnauthorizedFailure('Unauthorized', message: 'Phien dang nhap het han'),
      );
    } on NetworkException {
      return const Left(
        NetworkFailure('Network error', message: 'Khong co ket noi internet'),
      );
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Loi khong xac dinh'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteScene(int sceneId) async {
    try {
      await remoteDataSource.deleteScene(sceneId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } on NetworkException {
      return const Left(
        NetworkFailure('Network error', message: 'Khong co ket noi internet'),
      );
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Loi khong xac dinh'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleScene(int sceneId, bool enabled) async {
    try {
      await remoteDataSource.toggleScene(sceneId, enabled);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } on NetworkException {
      return const Left(
        NetworkFailure('Network error', message: 'Khong co ket noi internet'),
      );
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Loi khong xac dinh'));
    }
  }
}
