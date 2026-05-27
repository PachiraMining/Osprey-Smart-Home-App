import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/automation_repository.dart';

class DeleteAutomation {
  final AutomationRepository repository;
  DeleteAutomation(this.repository);

  Future<Either<Failure, void>> call(String sceneId) async {
    return await repository.deleteAutomation(sceneId);
  }
}
