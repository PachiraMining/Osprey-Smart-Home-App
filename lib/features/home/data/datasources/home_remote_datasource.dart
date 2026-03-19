import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/home_model.dart';
import '../models/home_device_model.dart';
import '../models/room_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<HomeModel>> getHomes();
  Future<HomeModel> createHome(Map<String, dynamic> body);
  Future<HomeModel> updateHome(String homeId, Map<String, dynamic> body);
  Future<void> deleteHome(String homeId);

  Future<List<HomeDeviceModel>> getHomeDevices(String homeId);
  Future<void> addDeviceToHome(String homeId, Map<String, dynamic> body);
  Future<void> updateHomeDevice(String homeId, String deviceId, Map<String, dynamic> body);
  Future<void> removeDeviceFromHome(String homeId, String deviceId);

  Future<List<RoomModel>> getRooms(String homeId);
  Future<RoomModel> createRoom(String homeId, Map<String, dynamic> body);
  Future<RoomModel> updateRoom(String homeId, String roomId, Map<String, dynamic> body);
  Future<void> deleteRoom(String homeId, String roomId);

  Future<Map<String, dynamic>> getDeviceInfo(String deviceId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient apiClient;

  HomeRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<HomeModel>> getHomes() async {
    try {
      final response = await apiClient.get('/api/smarthome/homes');
      final List<dynamic> data = response.data is List ? response.data : [];
      return data
          .map((json) => HomeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to get homes: ${e.message}');
    }
  }

  @override
  Future<HomeModel> createHome(Map<String, dynamic> body) async {
    try {
      final response = await apiClient.post('/api/smarthome/homes', data: body);
      return HomeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to create home: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<HomeModel> updateHome(String homeId, Map<String, dynamic> body) async {
    try {
      final response = await apiClient.put(
        '/api/smarthome/homes/$homeId',
        data: body,
      );
      return HomeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to update home: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> deleteHome(String homeId) async {
    try {
      await apiClient.delete('/api/smarthome/homes/$homeId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to delete home: ${e.message}');
    }
  }

  @override
  Future<List<HomeDeviceModel>> getHomeDevices(String homeId) async {
    try {
      final response = await apiClient.get('/api/smarthome/homes/$homeId/devices');
      final List<dynamic> data = response.data is List ? response.data : [];
      return data
          .map((json) => HomeDeviceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to get home devices: ${e.message}');
    }
  }

  @override
  Future<void> addDeviceToHome(String homeId, Map<String, dynamic> body) async {
    try {
      await apiClient.post('/api/smarthome/homes/$homeId/devices', data: body);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to add device to home: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> updateHomeDevice(
    String homeId,
    String deviceId,
    Map<String, dynamic> body,
  ) async {
    try {
      await apiClient.put(
        '/api/smarthome/homes/$homeId/devices/$deviceId',
        data: body,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to update home device: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> removeDeviceFromHome(String homeId, String deviceId) async {
    try {
      await apiClient.delete('/api/smarthome/homes/$homeId/devices/$deviceId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to remove device from home: ${e.message}');
    }
  }

  @override
  Future<List<RoomModel>> getRooms(String homeId) async {
    try {
      final response = await apiClient.get('/api/smarthome/homes/$homeId/rooms');
      final List<dynamic> data = response.data is List ? response.data : [];
      return data
          .map((json) => RoomModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to get rooms: ${e.message}');
    }
  }

  @override
  Future<RoomModel> createRoom(String homeId, Map<String, dynamic> body) async {
    try {
      final response = await apiClient.post(
        '/api/smarthome/homes/$homeId/rooms',
        data: body,
      );
      return RoomModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to create room: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<RoomModel> updateRoom(
    String homeId,
    String roomId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await apiClient.put(
        '/api/smarthome/homes/$homeId/rooms/$roomId',
        data: body,
      );
      return RoomModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to update room: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> deleteRoom(String homeId, String roomId) async {
    try {
      await apiClient.delete('/api/smarthome/homes/$homeId/rooms/$roomId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to delete room: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getDeviceInfo(String deviceId) async {
    try {
      final response = await apiClient.get('/api/device/$deviceId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to get device info: ${e.message}');
    }
  }
}
