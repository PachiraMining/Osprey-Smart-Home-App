import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/automation_scene_entity.dart';
import '../repositories/automation_repository.dart';

class GetAutomations {
  final AutomationRepository repository;
  GetAutomations(this.repository);

  Future<Either<Failure, List<AutomationSceneEntity>>> call(
      String homeId) async {
    return await repository.getAutomations(homeId);
  }
}
