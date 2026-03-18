import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/smart_home_entity.dart';
import '../entities/tap_to_run_scene_entity.dart';
import '../entities/scene_action_entity.dart';
import '../entities/data_point_entity.dart';

abstract class TapToRunRepository {
  Future<Either<Failure, List<SmartHomeEntity>>> getSmartHomes();
  Future<Either<Failure, List<TapToRunSceneEntity>>> getScenes(String homeId);
  Future<Either<Failure, TapToRunSceneEntity>> createScene({
    required String homeId,
    required String name,
    String? icon,
    required List<SceneActionEntity> actions,
  });
  Future<Either<Failure, TapToRunSceneEntity>> updateScene({
    required String sceneId,
    required String name,
    String? icon,
    required List<SceneActionEntity> actions,
  });
  Future<Either<Failure, void>> deleteScene(String sceneId);
  Future<Either<Failure, Map<String, dynamic>>> executeScene(String sceneId);
  Future<Either<Failure, void>> toggleScene(String sceneId, bool enabled);
  Future<Either<Failure, List<DataPointEntity>>> getDeviceDataPoints(String deviceProfileId);
}
