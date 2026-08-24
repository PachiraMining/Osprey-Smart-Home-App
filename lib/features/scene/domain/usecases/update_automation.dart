import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/automation_scene_entity.dart';
import '../entities/scene_action_entity.dart';
import '../entities/automation_condition_entity.dart';
import '../entities/effective_time_entity.dart';
import '../repositories/automation_repository.dart';

class UpdateAutomation {
  final AutomationRepository repository;
  UpdateAutomation(this.repository);

  Future<Either<Failure, AutomationSceneEntity>> call({
    required String sceneId,
    required String name,
    String? icon,
    required bool enabled,
    required List<AutomationConditionEntity> conditions,
    required String conditionLogic,
    EffectiveTimeEntity? effectiveTime,
    required List<SceneActionEntity> actions,
  }) async {
    return await repository.updateAutomation(
      sceneId: sceneId,
      name: name,
      icon: icon,
      enabled: enabled,
      conditions: conditions,
      conditionLogic: conditionLogic,
      effectiveTime: effectiveTime,
      actions: actions,
    );
  }
}
