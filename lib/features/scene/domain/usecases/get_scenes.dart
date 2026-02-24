import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/scene_entity.dart';
import '../repositories/scene_repository.dart';

class GetScenes {
  final SceneRepository repository;

  GetScenes(this.repository);

  Future<Either<Failure, List<SceneEntity>>> call() async {
    return await repository.getScenes();
  }
}
