import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/tap_to_run_repository.dart';

class ExecuteTapToRunScene {
  final TapToRunRepository repository;
  ExecuteTapToRunScene(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String sceneId) async {
    return await repository.executeScene(sceneId);
  }
}
