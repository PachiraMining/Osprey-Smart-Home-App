import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/tap_to_run_scene_entity.dart';
import '../../domain/entities/scene_action_entity.dart';
import '../../domain/entities/data_point_entity.dart';
import '../../domain/repositories/tap_to_run_repository.dart';
import '../datasources/tap_to_run_remote_datasource.dart';
import '../models/scene_action_model.dart';

class TapToRunRepositoryImpl implements TapToRunRepository {
  final TapToRunRemoteDataSource remoteDataSource;

  TapToRunRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TapToRunSceneEntity>>> getScenes(String homeId) async {
    try {
      final scenes = await remoteDataSource.getScenes(homeId);
      return Right(scenes);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Unknown error'));
    }
  }

  @override
  Future<Either<Failure, TapToRunSceneEntity>> createScene({
    required String homeId,
    required String name,
    String? icon,
    required List<SceneActionEntity> actions,
  }) async {
    try {
      final body = {
        'name': name,
        'sceneType': 'TAP_TO_RUN',
        if (icon != null) 'icon': icon,
        'actions': actions.map((a) {
          final model = SceneActionModel(
            actionType: a.actionType,
            entityId: a.entityId,
            executorProperty: a.executorProperty,
          );
          return model.toJson();
        }).toList(),
      };
      final scene = await remoteDataSource.createScene(homeId, body);
      return Right(scene);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Unknown error'));
    }
  }

  @override
  Future<Either<Failure, TapToRunSceneEntity>> updateScene({
    required String sceneId,
    required String name,
    String? icon,
    required List<SceneActionEntity> actions,
  }) async {
    try {
      final body = {
        'name': name,
        'sceneType': 'TAP_TO_RUN',
        if (icon != null) 'icon': icon,
        'actions': actions.map((a) {
          final model = SceneActionModel(
            actionType: a.actionType,
            entityId: a.entityId,
            executorProperty: a.executorProperty,
          );
          return model.toJson();
        }).toList(),
      };
      final scene = await remoteDataSource.updateScene(sceneId, body);
      return Right(scene);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Unknown error'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteScene(String sceneId) async {
    try {
      await remoteDataSource.deleteScene(sceneId);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Unknown error'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> executeScene(String sceneId) async {
    try {
      // Backend chạy scene bất đồng bộ: POST /execute trả 200 body rỗng, kết
      // quả thật được ghi vào /logs ngay sau đó. Snapshot log mới nhất trước
      // khi execute để nhận ra entry của đúng lượt chạy này.
      String? lastLogId;
      try {
        final before = await remoteDataSource.getSceneLogs(sceneId);
        if (before.isNotEmpty) lastLogId = before.first['id'] as String?;
      } catch (_) {
        // Không đọc được logs không chặn việc execute.
      }

      await remoteDataSource.executeScene(sceneId);

      for (var attempt = 0; attempt < 4; attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 700));
        try {
          final logs = await remoteDataSource.getSceneLogs(sceneId);
          if (logs.isNotEmpty && logs.first['id'] != lastLogId) {
            return Right(logs.first);
          }
        } catch (_) {
          // Lỗi đọc log tạm thời — thử lại ở vòng sau.
        }
      }
      // Server đã nhận lệnh (200) nhưng log chưa kịp xuất hiện — coi là thành
      // công thay vì báo lỗi sai như trước.
      return const Right({'status': 'SUCCESS'});
    } on SceneDisabledException catch (e) {
      return Left(SceneDisabledFailure(e.message, message: e.message));
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Unknown error'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleScene(String sceneId, bool enabled) async {
    try {
      if (enabled) {
        await remoteDataSource.enableScene(sceneId);
      } else {
        await remoteDataSource.disableScene(sceneId);
      }
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Unknown error'));
    }
  }

  @override
  Future<Either<Failure, List<DataPointEntity>>> getDeviceDataPoints(String deviceProfileId) async {
    try {
      final dataPoints = await remoteDataSource.getDeviceDataPoints(deviceProfileId);
      return Right(dataPoints);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Unknown error'));
    }
  }
}
