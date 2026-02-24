import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../models/scene_model.dart';

abstract class SceneRemoteDataSource {
  Future<List<SceneModel>> getScenes(String userId);
  Future<SceneModel> createScene(Map<String, dynamic> data);
  Future<void> deleteScene(int sceneId);
  Future<void> toggleScene(int sceneId, bool enabled);
  Future<String> getDeviceToken(String deviceId);
}

class SceneRemoteDataSourceImpl implements SceneRemoteDataSource {
  final http.Client client;
  final String schedulerBaseUrl;
  final String thingsboardBaseUrl;
  final String Function() getToken;
  final String Function() getCustomerId;

  SceneRemoteDataSourceImpl({
    required this.client,
    required this.schedulerBaseUrl,
    required this.thingsboardBaseUrl,
    required this.getToken,
    required this.getCustomerId,
  });

  Map<String, String> get _thingsboardHeaders => {
    'Content-Type': 'application/json',
    'accept': 'application/json',
    'X-Authorization': 'Bearer ${getToken()}',
  };

  Map<String, String> get _schedulerHeaders => {
    'Content-Type': 'application/json',
    'accept': 'application/json',
  };

  @override
  Future<List<SceneModel>> getScenes(String userId) async {
    try {
      final url = '$schedulerBaseUrl/scenes/?user_id=$userId';
      print('[SceneDS] GET $url');

      final response = await client.get(
        Uri.parse(url),
        headers: _schedulerHeaders,
      );

      print('[SceneDS] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => SceneModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: 'Failed to load scenes: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[SceneDS] Error getScenes: $e');
      if (e is ServerException) rethrow;
      throw NetworkException();
    }
  }

  @override
  Future<SceneModel> createScene(Map<String, dynamic> data) async {
    try {
      final url = '$schedulerBaseUrl/scenes/';
      print('[SceneDS] POST $url');
      print('[SceneDS] Body: ${jsonEncode(data)}');

      final response = await client.post(
        Uri.parse(url),
        headers: _schedulerHeaders,
        body: jsonEncode(data),
      );

      print('[SceneDS] Status: ${response.statusCode}');
      print('[SceneDS] Response: ${response.body}');

      if (response.statusCode == 200) {
        return SceneModel.fromJson(jsonDecode(response.body));
      } else {
        throw ServerException(
          message: 'Failed to create scene: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('[SceneDS] Error createScene: $e');
      if (e is ServerException) rethrow;
      throw NetworkException();
    }
  }

  @override
  Future<void> deleteScene(int sceneId) async {
    try {
      final url = '$schedulerBaseUrl/scenes/$sceneId';
      print('[SceneDS] DELETE $url');

      final response = await client.delete(
        Uri.parse(url),
        headers: _schedulerHeaders,
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to delete scene: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException();
    }
  }

  @override
  Future<void> toggleScene(int sceneId, bool enabled) async {
    try {
      final url = '$schedulerBaseUrl/scenes/$sceneId/toggle?enabled=$enabled';
      print('[SceneDS] POST $url');

      final response = await client.post(
        Uri.parse(url),
        headers: _schedulerHeaders,
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to toggle scene: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException();
    }
  }

  @override
  Future<String> getDeviceToken(String deviceId) async {
    try {
      final url = '$thingsboardBaseUrl/api/device/$deviceId/credentials';
      print('[SceneDS] GET device credentials: $url');

      final response = await client.get(
        Uri.parse(url),
        headers: _thingsboardHeaders,
      );

      print('[SceneDS] Credentials status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final credentialsId = json['credentialsId'] as String;
        print('[SceneDS] Device token: $credentialsId');
        return credentialsId;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException(
          message: 'Failed to get device credentials: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[SceneDS] Error getDeviceToken: $e');
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw NetworkException();
    }
  }
}
