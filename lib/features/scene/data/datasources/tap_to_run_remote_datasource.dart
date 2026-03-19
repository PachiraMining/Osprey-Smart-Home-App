import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/tap_to_run_scene_model.dart';
import '../models/data_point_model.dart';

abstract class TapToRunRemoteDataSource {
  Future<List<TapToRunSceneModel>> getScenes(String homeId);
  Future<TapToRunSceneModel> getSceneDetail(String sceneId);
  Future<TapToRunSceneModel> createScene(String homeId, Map<String, dynamic> body);
  Future<TapToRunSceneModel> updateScene(String sceneId, Map<String, dynamic> body);
  Future<void> deleteScene(String sceneId);
  Future<Map<String, dynamic>> executeScene(String sceneId);
  Future<void> enableScene(String sceneId);
  Future<void> disableScene(String sceneId);
  Future<List<DataPointModel>> getDeviceDataPoints(String deviceProfileId);
}

class TapToRunRemoteDataSourceImpl implements TapToRunRemoteDataSource {
  final ApiClient apiClient;

  TapToRunRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<TapToRunSceneModel>> getScenes(String homeId) async {
    try {
      final response = await apiClient.get(
        '/api/smarthome/homes/$homeId/scenes',
        queryParameters: {'sceneType': 'TAP_TO_RUN'},
      );
      final List<dynamic> data = response.data is List ? response.data : [];
      return data
          .map((json) => TapToRunSceneModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to get scenes: ${e.message}');
    }
  }

  @override
  Future<TapToRunSceneModel> getSceneDetail(String sceneId) async {
    try {
      final response = await apiClient.get('/api/smarthome/scenes/$sceneId');
      return TapToRunSceneModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to get scene detail: ${e.message}');
    }
  }

  @override
  Future<TapToRunSceneModel> createScene(String homeId, Map<String, dynamic> body) async {
    try {
      final response = await apiClient.post(
        '/api/smarthome/homes/$homeId/scenes',
        data: body,
      );
      return TapToRunSceneModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to create scene: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<TapToRunSceneModel> updateScene(String sceneId, Map<String, dynamic> body) async {
    try {
      final response = await apiClient.put(
        '/api/smarthome/scenes/$sceneId',
        data: body,
      );
      return TapToRunSceneModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to update scene: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> deleteScene(String sceneId) async {
    try {
      await apiClient.delete('/api/smarthome/scenes/$sceneId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to delete scene: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> executeScene(String sceneId) async {
    try {
      final response = await apiClient.post('/api/smarthome/scenes/$sceneId/execute');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to execute scene: ${e.message}');
    }
  }

  @override
  Future<void> enableScene(String sceneId) async {
    try {
      await apiClient.put('/api/smarthome/scenes/$sceneId/enable');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to enable scene: ${e.message}');
    }
  }

  @override
  Future<void> disableScene(String sceneId) async {
    try {
      await apiClient.put('/api/smarthome/scenes/$sceneId/disable');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to disable scene: ${e.message}');
    }
  }

  @override
  Future<List<DataPointModel>> getDeviceDataPoints(String deviceProfileId) async {
    try {
      final response = await apiClient.get(
        '/api/smarthome/products/$deviceProfileId/datapoints',
      );
      final List<dynamic> data = response.data is List ? response.data : [];
      return data
          .map((json) => DataPointModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to get datapoints: ${e.message}');
    }
  }
}
