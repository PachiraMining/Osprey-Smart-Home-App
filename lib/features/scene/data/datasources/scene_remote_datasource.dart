import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/scene_model.dart';

abstract class SceneRemoteDataSource {
  Future<List<SceneModel>> getScenes(String homeId);
  Future<SceneModel> createScene(String homeId, Map<String, dynamic> data);
  Future<void> deleteScene(String sceneId);
  Future<void> toggleScene(String sceneId, bool enabled);
}

class SceneRemoteDataSourceImpl implements SceneRemoteDataSource {
  final ApiClient apiClient;

  SceneRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<SceneModel>> getScenes(String homeId) async {
    try {
      final response = await apiClient.get(
        '/api/smarthome/homes/$homeId/scenes',
        queryParameters: {'sceneType': 'AUTOMATION'},
      );
      final List<dynamic> data = response.data is List ? response.data : [];
      return data
          .map((json) => SceneModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(message: 'Failed to get scenes: ${e.message}');
    }
  }

  @override
  Future<SceneModel> createScene(String homeId, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post(
        '/api/smarthome/homes/$homeId/scenes',
        data: data,
      );
      return SceneModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(
          message: 'Failed to create scene: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> deleteScene(String sceneId) async {
    try {
      await apiClient.delete('/api/smarthome/scenes/$sceneId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(message: 'Failed to delete scene: ${e.message}');
    }
  }

  @override
  Future<void> toggleScene(String sceneId, bool enabled) async {
    try {
      if (enabled) {
        await apiClient.put('/api/smarthome/scenes/$sceneId/enable');
      } else {
        await apiClient.put('/api/smarthome/scenes/$sceneId/disable');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(message: 'Failed to toggle scene: ${e.message}');
    }
  }
}
