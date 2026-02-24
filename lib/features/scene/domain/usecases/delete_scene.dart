import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/scene_repository.dart';

class DeleteScene {
  final SceneRepository repository;

  DeleteScene(this.repository);

  Future<Either<Failure, void>> call(int sceneId) async {
    return await repository.deleteScene(sceneId);
  }
}
