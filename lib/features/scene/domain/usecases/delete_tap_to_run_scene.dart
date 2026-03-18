import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/tap_to_run_repository.dart';

class DeleteTapToRunScene {
  final TapToRunRepository repository;
  DeleteTapToRunScene(this.repository);

  Future<Either<Failure, void>> call(String sceneId) async {
    return await repository.deleteScene(sceneId);
  }
}
