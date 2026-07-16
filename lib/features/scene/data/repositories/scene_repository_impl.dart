import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/scene_entity.dart';
import '../../domain/repositories/scene_repository.dart';
import '../datasources/scene_remote_datasource.dart';

class SceneRepositoryImpl implements SceneRepository {
  final SceneRemoteDataSource remoteDataSource;
  final String Function() getHomeId;

  SceneRepositoryImpl({
    required this.remoteDataSource,
    required this.getHomeId,
  });

  @override
  Future<Either<Failure, List<SceneEntity>>> getScenes() async {
    try {
      final homeId = getHomeId();
      if (homeId.isEmpty) {
        return const Left(
          ServerFailure('HomeId not found', message: 'Vui long chon home truoc'),
        );
      }
      final scenes = await remoteDataSource.getScenes(homeId);
      return Right(scenes);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } on UnauthorizedException {
      return const Left(
        UnauthorizedFailure('Unauthorized', message: 'Phien dang nhap het han'),
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
      final homeId = getHomeId();
      if (homeId.isEmpty) {
        return const Left(
          ServerFailure('HomeId not found', message: 'Vui long chon home truoc'),
        );
      }

      final loops = _buildLoops(daysOfWeek, repeatMode);
      final data = {
        'name': name,
        'sceneType': 'AUTOMATION',
        'enabled': true,
        'conditions': [
          {
            'conditionType': 'SCHEDULE',
            'time': time,
            'loops': loops,
            // No timeZoneId: the backend derives the zone from home.timezone so
            // the scene fires in the Home's local time. (Sending a hardcoded
            // 'Asia/Ho_Chi_Minh' forced every scene to VN regardless of home.)
          },
        ],
        'conditionLogic': 'AND',
        'actions': [
          {
            'entityId': deviceId,
            'actionType': 'DEVICE_CONTROL',
            'executorProperty': {
              'dpId': 1,
              'dpValue': action,
            },
          },
        ],
      };

      final scene = await remoteDataSource.createScene(homeId, data);
      return Right(scene);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } on UnauthorizedException {
      return const Left(
        UnauthorizedFailure('Unauthorized', message: 'Phien dang nhap het han'),
      );
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Loi khong xac dinh'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteScene(String sceneId) async {
    try {
      await remoteDataSource.deleteScene(sceneId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } on UnauthorizedException {
      return const Left(
        UnauthorizedFailure('Unauthorized', message: 'Phien dang nhap het han'),
      );
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Loi khong xac dinh'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleScene(String sceneId, bool enabled) async {
    try {
      await remoteDataSource.toggleScene(sceneId, enabled);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } on UnauthorizedException {
      return const Left(
        UnauthorizedFailure('Unauthorized', message: 'Phien dang nhap het han'),
      );
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Loi khong xac dinh'));
    }
  }

  String _buildLoops(String daysOfWeek, String repeatMode) {
    if (repeatMode == 'daily') return '1111111';
    if (repeatMode == 'once') return '0000000';
    final days = daysOfWeek.split(',').map((e) => int.tryParse(e.trim()) ?? 0).toSet();
    final buf = StringBuffer();
    for (int i = 1; i <= 7; i++) {
      buf.write(days.contains(i) ? '1' : '0');
    }
    return buf.toString();
  }
}
