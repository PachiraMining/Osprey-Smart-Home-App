import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/automation_scene_entity.dart';
import '../../domain/entities/scene_action_entity.dart';
import '../../domain/entities/schedule_condition_entity.dart';
import '../../domain/entities/effective_time_entity.dart';
import '../../domain/repositories/automation_repository.dart';
import '../datasources/automation_remote_datasource.dart';
import '../models/scene_action_model.dart';
import '../models/schedule_condition_model.dart';
import '../models/effective_time_model.dart';

class AutomationRepositoryImpl implements AutomationRepository {
  final AutomationRemoteDataSource remoteDataSource;

  AutomationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AutomationSceneEntity>>> getAutomations(
      String homeId) async {
    try {
      final automations = await remoteDataSource.getAutomations(homeId);
      return Right(automations);
    } on UnauthorizedException {
      return const Left(
          UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e, stackTrace) {
      print('🔴 [Automation] error: $e\n$stackTrace');
      return Left(ServerFailure('$e', message: '$e'));
    }
  }

  @override
  Future<Either<Failure, AutomationSceneEntity>> getAutomationDetail(
      String sceneId) async {
    try {
      final automation =
          await remoteDataSource.getAutomationDetail(sceneId);
      return Right(automation);
    } on UnauthorizedException {
      return const Left(
          UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e, stackTrace) {
      print('🔴 [Automation] error: $e\n$stackTrace');
      return Left(ServerFailure('$e', message: '$e'));
    }
  }

  @override
  Future<Either<Failure, AutomationSceneEntity>> createAutomation({
    required String homeId,
    required String name,
    String? icon,
    required List<ScheduleConditionEntity> conditions,
    required String conditionLogic,
    EffectiveTimeEntity? effectiveTime,
    required List<SceneActionEntity> actions,
  }) async {
    try {
      final body = _buildBody(
        name: name,
        icon: icon,
        conditions: conditions,
        conditionLogic: conditionLogic,
        effectiveTime: effectiveTime,
        actions: actions,
      );
      final automation =
          await remoteDataSource.createAutomation(homeId, body);
      return Right(automation);
    } on UnauthorizedException {
      return const Left(
          UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e, stackTrace) {
      print('🔴 [Automation] error: $e\n$stackTrace');
      return Left(ServerFailure('$e', message: '$e'));
    }
  }

  @override
  Future<Either<Failure, AutomationSceneEntity>> updateAutomation({
    required String sceneId,
    required String name,
    String? icon,
    required bool enabled,
    required List<ScheduleConditionEntity> conditions,
    required String conditionLogic,
    EffectiveTimeEntity? effectiveTime,
    required List<SceneActionEntity> actions,
  }) async {
    try {
      final body = _buildBody(
        name: name,
        icon: icon,
        conditions: conditions,
        conditionLogic: conditionLogic,
        effectiveTime: effectiveTime,
        actions: actions,
      );
      body['enabled'] = enabled;
      final automation =
          await remoteDataSource.updateAutomation(sceneId, body);
      return Right(automation);
    } on UnauthorizedException {
      return const Left(
          UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e, stackTrace) {
      print('🔴 [Automation] error: $e\n$stackTrace');
      return Left(ServerFailure('$e', message: '$e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAutomation(String sceneId) async {
    try {
      await remoteDataSource.deleteAutomation(sceneId);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(
          UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e, stackTrace) {
      print('🔴 [Automation] error: $e\n$stackTrace');
      return Left(ServerFailure('$e', message: '$e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleAutomation(
      String sceneId, bool enabled) async {
    try {
      if (enabled) {
        await remoteDataSource.enableAutomation(sceneId);
      } else {
        await remoteDataSource.disableAutomation(sceneId);
      }
      return const Right(null);
    } on UnauthorizedException {
      return const Left(
          UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e, stackTrace) {
      print('🔴 [Automation] error: $e\n$stackTrace');
      return Left(ServerFailure('$e', message: '$e'));
    }
  }

  Map<String, dynamic> _buildBody({
    required String name,
    String? icon,
    required List<ScheduleConditionEntity> conditions,
    required String conditionLogic,
    EffectiveTimeEntity? effectiveTime,
    required List<SceneActionEntity> actions,
  }) {
    return {
      'name': name,
      'sceneType': 'AUTOMATION',
      if (icon != null) 'icon': icon,
      'conditions': conditions.map((c) {
        return ScheduleConditionModel(
          conditionType: c.conditionType,
          timeZoneId: c.timeZoneId,
          loops: c.loops,
          time: c.time,
          date: c.date,
        ).toJson();
      }).toList(),
      'conditionLogic': conditionLogic,
      if (effectiveTime != null)
        'effectiveTime': EffectiveTimeModel(
          type: effectiveTime.type,
          startTime: effectiveTime.startTime,
          endTime: effectiveTime.endTime,
          loops: effectiveTime.loops,
          timeZoneId: effectiveTime.timeZoneId,
        ).toJson(),
      'actions': actions.map((a) {
        return SceneActionModel(
          actionType: a.actionType,
          entityId: a.entityId,
          executorProperty: a.executorProperty,
        ).toJson();
      }).toList(),
    };
  }
}
