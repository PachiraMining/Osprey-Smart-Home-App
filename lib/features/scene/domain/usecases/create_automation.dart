import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/automation_scene_entity.dart';
import '../entities/scene_action_entity.dart';
import '../entities/automation_condition_entity.dart';
import '../entities/effective_time_entity.dart';
import '../repositories/automation_repository.dart';

class CreateAutomation {
  final AutomationRepository repository;
  CreateAutomation(this.repository);

  Future<Either<Failure, AutomationSceneEntity>> call({
    required String homeId,
    required String name,
    String? icon,
    required List<AutomationConditionEntity> conditions,
    required String conditionLogic,
    EffectiveTimeEntity? effectiveTime,
    required List<SceneActionEntity> actions,
  }) async {
    return await repository.createAutomation(
      homeId: homeId,
      name: name,
      icon: icon,
      conditions: conditions,
      conditionLogic: conditionLogic,
      effectiveTime: effectiveTime,
      actions: actions,
    );
  }
}
