import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/automation_scene_model.dart';

abstract class AutomationRemoteDataSource {
  Future<List<AutomationSceneModel>> getAutomations(String homeId);
  Future<AutomationSceneModel> getAutomationDetail(String sceneId);
  Future<AutomationSceneModel> createAutomation(
      String homeId, Map<String, dynamic> body);
  Future<AutomationSceneModel> updateAutomation(
      String sceneId, Map<String, dynamic> body);
  Future<void> deleteAutomation(String sceneId);
  Future<void> enableAutomation(String sceneId);
  Future<void> disableAutomation(String sceneId);
}

class AutomationRemoteDataSourceImpl implements AutomationRemoteDataSource {
  final ApiClient apiClient;

  AutomationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<AutomationSceneModel>> getAutomations(String homeId) async {
    try {
      print('🤖 [Automation] GET scenes for home=$homeId');
      final response = await apiClient.get(
        '/api/smarthome/homes/$homeId/scenes',
        queryParameters: {'sceneType': 'AUTOMATION'},
      );
      final List<dynamic> data =
          response.data is List ? response.data : [];
      print('🤖 [Automation] getAutomations: ${data.length} items');
      return data.map((json) {
        try {
          return AutomationSceneModel.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          print('🔴 [Automation] Failed to parse: $json\nError: $e');
          rethrow;
        }
      }).toList();
    } on DioException catch (e) {
      print('🔴 [Automation] getAutomations DioError: ${e.response?.statusCode} ${e.message}');
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(
          message: 'Failed to get automations: ${e.message}');
    }
  }

  @override
  Future<AutomationSceneModel> getAutomationDetail(String sceneId) async {
    try {
      print('🤖 [Automation] GET detail for scene=$sceneId');
      final response =
          await apiClient.get('/api/smarthome/scenes/$sceneId');
      print('🤖 [Automation] getDetail response: ${response.data}');
      return AutomationSceneModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('🔴 [Automation] getDetail DioError: ${e.response?.statusCode} ${e.message}');
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(
          message: 'Failed to get automation detail: ${e.message}');
    }
  }

  @override
  Future<AutomationSceneModel> createAutomation(
      String homeId, Map<String, dynamic> body) async {
    try {
      print('🤖 [Automation] POST create for home=$homeId');
      print('🤖 [Automation] Body: $body');
      final response = await apiClient.post(
        '/api/smarthome/homes/$homeId/scenes',
        data: body,
      );
      print('🤖 [Automation] createAutomation response: ${response.data}');
      return AutomationSceneModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('🔴 [Automation] create DioError: ${e.response?.statusCode} ${e.response?.data}');
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(
          message:
              'Failed to create automation: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<AutomationSceneModel> updateAutomation(
      String sceneId, Map<String, dynamic> body) async {
    try {
      print('🤖 [Automation] PUT update scene=$sceneId');
      print('🤖 [Automation] Body: $body');
      final response = await apiClient.put(
        '/api/smarthome/scenes/$sceneId',
        data: body,
      );
      print('🤖 [Automation] updateAutomation response: ${response.data}');
      return AutomationSceneModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('🔴 [Automation] update DioError: ${e.response?.statusCode} ${e.response?.data}');
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(
          message:
              'Failed to update automation: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> deleteAutomation(String sceneId) async {
    try {
      print('🤖 [Automation] DELETE scene=$sceneId');
      await apiClient.delete('/api/smarthome/scenes/$sceneId');
      print('🤖 [Automation] deleteAutomation OK');
    } on DioException catch (e) {
      print('🔴 [Automation] delete DioError: ${e.response?.statusCode} ${e.message}');
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(
          message: 'Failed to delete automation: ${e.message}');
    }
  }

  @override
  Future<void> enableAutomation(String sceneId) async {
    try {
      print('🤖 [Automation] PUT enable scene=$sceneId');
      await apiClient.put('/api/smarthome/scenes/$sceneId/enable');
      print('🤖 [Automation] enableAutomation OK');
    } on DioException catch (e) {
      print('🔴 [Automation] enable DioError: ${e.response?.statusCode} ${e.message}');
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(
          message: 'Failed to enable automation: ${e.message}');
    }
  }

  @override
  Future<void> disableAutomation(String sceneId) async {
    try {
      print('🤖 [Automation] PUT disable scene=$sceneId');
      await apiClient.put('/api/smarthome/scenes/$sceneId/disable');
      print('🤖 [Automation] disableAutomation OK');
    } on DioException catch (e) {
      print('🔴 [Automation] disable DioError: ${e.response?.statusCode} ${e.message}');
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(
          message: 'Failed to disable automation: ${e.message}');
    }
  }
}
