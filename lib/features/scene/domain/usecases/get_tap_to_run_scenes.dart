import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/tap_to_run_scene_entity.dart';
import '../repositories/tap_to_run_repository.dart';

class GetTapToRunScenes {
  final TapToRunRepository repository;
  GetTapToRunScenes(this.repository);

  Future<Either<Failure, List<TapToRunSceneEntity>>> call(String homeId) async {
    return await repository.getScenes(homeId);
  }
}
