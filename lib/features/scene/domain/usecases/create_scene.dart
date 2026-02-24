import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/scene_entity.dart';
import '../repositories/scene_repository.dart';

class CreateScene {
  final SceneRepository repository;

  CreateScene(this.repository);

  Future<Either<Failure, SceneEntity>> call({
    required String deviceId,
    required String name,
    required String action,
    required String time,
    required String daysOfWeek,
    required String repeatMode,
  }) async {
    return await repository.createScene(
      deviceId: deviceId,
      name: name,
      action: action,
      time: time,
      daysOfWeek: daysOfWeek,
      repeatMode: repeatMode,
    );
  }
}
