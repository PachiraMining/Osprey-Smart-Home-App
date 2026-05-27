import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/automation_repository.dart';

class ToggleAutomation {
  final AutomationRepository repository;
  ToggleAutomation(this.repository);

  Future<Either<Failure, void>> call(String sceneId, bool enabled) async {
    return await repository.toggleAutomation(sceneId, enabled);
  }
}
