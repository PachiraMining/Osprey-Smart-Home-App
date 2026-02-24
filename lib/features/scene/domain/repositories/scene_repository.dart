import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/scene_entity.dart';

abstract class SceneRepository {
  Future<Either<Failure, List<SceneEntity>>> getScenes();
  Future<Either<Failure, SceneEntity>> createScene({
    required String deviceId,
    required String name,
    required String action,
    required String time,
    required String daysOfWeek,
    required String repeatMode,
  });
  Future<Either<Failure, void>> deleteScene(int sceneId);
  Future<Either<Failure, void>> toggleScene(int sceneId, bool enabled);
}
