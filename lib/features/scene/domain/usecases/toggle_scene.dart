import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/scene_repository.dart';

class ToggleScene {
  final SceneRepository repository;

  ToggleScene(this.repository);

  Future<Either<Failure, void>> call(int sceneId, bool enabled) async {
    return await repository.toggleScene(sceneId, enabled);
  }
}
