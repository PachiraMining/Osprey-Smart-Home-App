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

  /// Log mới nhất đã thấy của từng scene, giữ trong bộ nhớ phiên chạy.
  /// Nhờ nó, từ lần chạm thứ hai trở đi không cần request nào trước khi gửi
  /// lệnh — bấm là rèm chạy luôn.
  final Map<String, String> _lastLogId = {};

  @override
  Future<Either<Failure, Map<String, dynamic>>> executeScene(String sceneId) async {
    try {
      // Backend chạy scene bất đồng bộ: POST /execute trả 200 body rỗng, kết
      // quả thật được ghi vào /logs ngay sau đó. Cần biết log mới nhất TRƯỚC
      // lượt chạy này để nhận ra entry mới.
      //
      // Mốc đó KHÔNG được chặn lệnh: trước đây `await getSceneLogs` nằm trước
      // POST, nên rèm chỉ nhúc nhích sau trọn một vòng mạng — đúng cái độ trễ
      // 1-2s người dùng thấy. Giờ mốc lấy từ bộ nhớ (lần chạy trước của chính
      // scene đó), còn lần đầu thì bắn GET SONG SONG với POST.
      String? lastLogId = _lastLogId[sceneId];
      Future<void>? snapshot;
      if (lastLogId == null) {
        snapshot = remoteDataSource.getSceneLogs(sceneId).then((before) {
          if (before.isNotEmpty) lastLogId = before.first['id'] as String?;
        }).catchError((_) {
          // Không đọc được logs không chặn việc execute.
        });
      }

      await remoteDataSource.executeScene(sceneId);

      // Chờ mốc trước khi so sánh — lệnh đã đi rồi nên không ảnh hưởng độ trễ.
      if (snapshot != null) await snapshot;

      // CHỈ dò 2 lần. Bản trước dò 5 lần nên một lần chạm có thể thành 6-7
      // request — phía server đã phản ánh. Mỗi lần dò chỉ để biết scene chạy
      // thành công hay hỏng, không phải để điều khiển, nên cắt xuống 2 lần là
      // đủ bắt phần lớn ca hỏng mà không dội request.
      //
      // Gốc của việc phải dò: POST /execute trả 200 body RỖNG, không cho biết
      // kết quả. Nếu backend trả luôn kết quả (hoặc id log) trong response thì
      // bỏ được sạch phần dò này, còn đúng 1 request cho mỗi lần chạm.
      const waits = [
        Duration(milliseconds: 600),
        Duration(milliseconds: 1600),
      ];
      for (final wait in waits) {
        await Future<void>.delayed(wait);
        try {
          final logs = await remoteDataSource.getSceneLogs(sceneId);
          if (logs.isNotEmpty) {
            final newestId = logs.first['id'] as String?;
            // Nhớ lại để lần chạm sau khỏi phải đi lấy mốc nữa.
            if (newestId != null) _lastLogId[sceneId] = newestId;
            if (newestId != lastLogId) return Right(logs.first);
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
