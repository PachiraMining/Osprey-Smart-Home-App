// lib/features/device/data/datasources/device_remote_data_source.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../models/device_model.dart';

abstract class DeviceRemoteDataSource {
  Future<List<DeviceModel>> getCustomerDevices();
  Future<void> deleteDevice(String deviceId);
}

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final String Function() getToken;
  final String Function() getCustomerId;

  DeviceRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.getToken,
    required this.getCustomerId,
  });

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'accept': 'application/json',
    'X-Authorization': 'Bearer ${getToken()}',
  };

  @override
  Future<List<DeviceModel>> getCustomerDevices() async {
    try {
      final token = getToken();
      print('Token: ${token.isEmpty ? "EMPTY" : token.substring(0, 20)}...');
      final customerId = getCustomerId(); // THÊM
      print('Customer: ${customerId.isEmpty ? "EMPTY" : customerId}');
      if (customerId.isEmpty) {
        // THÊM
        throw ServerException(
          message: 'CustomerId not found. Please login again.',
        );
      }

      // DEBUG: Full URL
      final url =
          '$baseUrl/api/customer/$customerId/deviceInfos?pageSize=100&page=0&sortOrder=DESC';
      print('🌐 API URL: $url');

      final response = await client.get(Uri.parse(url), headers: _headers);

      // DEBUG: Response
      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> devicesList = json['data'] ?? [];

        print('✅ Found ${devicesList.length} devices');

        return devicesList
            .map((device) => DeviceModel.fromJson(device))
            .toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException(
          message: 'Failed to load devices: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error loading devices: $e');
      if (e is ServerException) rethrow;
      throw NetworkException();
    }
  }

  @override
  Future<void> deleteDevice(String deviceId) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/api/device/$deviceId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException(
          message: 'Failed to delete device: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException();
    }
  }
}
