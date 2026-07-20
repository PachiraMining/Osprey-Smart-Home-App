import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
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
        ApiEndpoints.homeScenes(homeId),
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
        ApiEndpoints.homeScenes(homeId),
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
      await apiClient.delete(ApiEndpoints.scene(sceneId));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(message: 'Failed to delete scene: ${e.message}');
    }
  }

  @override
  Future<void> toggleScene(String sceneId, bool enabled) async {
    try {
      if (enabled) {
        await apiClient.put(ApiEndpoints.sceneEnable(sceneId));
      } else {
        await apiClient.put(ApiEndpoints.sceneDisable(sceneId));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(message: 'Failed to toggle scene: ${e.message}');
    }
  }
}
