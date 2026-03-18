import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/tap_to_run_scene_entity.dart';
import '../entities/scene_action_entity.dart';
import '../repositories/tap_to_run_repository.dart';

class CreateTapToRunScene {
  final TapToRunRepository repository;
  CreateTapToRunScene(this.repository);

  Future<Either<Failure, TapToRunSceneEntity>> call({
    required String homeId,
    required String name,
    String? icon,
    required List<SceneActionEntity> actions,
  }) async {
    return await repository.createScene(
      homeId: homeId,
      name: name,
      icon: icon,
      actions: actions,
    );
  }
}
