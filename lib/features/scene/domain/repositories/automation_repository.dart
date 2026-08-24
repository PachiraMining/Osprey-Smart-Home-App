import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/automation_scene_entity.dart';
import '../entities/scene_action_entity.dart';
import '../entities/automation_condition_entity.dart';
import '../entities/effective_time_entity.dart';

abstract class AutomationRepository {
  Future<Either<Failure, List<AutomationSceneEntity>>> getAutomations(
      String homeId);

  Future<Either<Failure, AutomationSceneEntity>> getAutomationDetail(
      String sceneId);

  Future<Either<Failure, AutomationSceneEntity>> createAutomation({
    required String homeId,
    required String name,
    String? icon,
    required List<AutomationConditionEntity> conditions,
    required String conditionLogic,
    EffectiveTimeEntity? effectiveTime,
    required List<SceneActionEntity> actions,
  });

  Future<Either<Failure, AutomationSceneEntity>> updateAutomation({
    required String sceneId,
    required String name,
    String? icon,
    required bool enabled,
    required List<AutomationConditionEntity> conditions,
    required String conditionLogic,
    EffectiveTimeEntity? effectiveTime,
    required List<SceneActionEntity> actions,
  });

  Future<Either<Failure, void>> deleteAutomation(String sceneId);

  Future<Either<Failure, void>> toggleAutomation(
      String sceneId, bool enabled);
}
