// lib/features/device/data/datasources/device_control_data_source.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';

abstract class DeviceControlDataSource {
  Future<void> sendCommand(String deviceId, String command);
}

class DeviceControlDataSourceImpl implements DeviceControlDataSource {
  final http.Client client;
  final String baseUrl;
  final String Function() getToken;

  DeviceControlDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.getToken,
  });

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'accept': 'application/json',
    'X-Authorization': 'Bearer ${getToken()}',
  };

  @override
  Future<void> sendCommand(String deviceId, String command) async {
    try {
      print('📤 Sending command: $command to device: $deviceId');

      // Convert command to params
      int params;
      if (command == 'OPEN') {
        params = 1; // Mở rèm
      } else if (command == 'CLOSE') {
        params = 0; // Đóng rèm
      } else if (command == 'STOP') {
        params = 2; // Dừng
      } else {
        params = 0;
      }

      // Body theo format API của bạn
      final body = jsonEncode({'method': 'setRelayState', 'params': params});

      print('📦 Request body: $body');
      print('🔑 Token: ${getToken().substring(0, 20)}...');

      // Gọi API
      final response = await client.post(
        Uri.parse('$baseUrl/api/rpc/oneway/$deviceId'),
        headers: _headers,
        body: body,
      );

      print('📡 Response: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Command sent successfully');
        return;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException(
          message: 'Failed to send command: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error sending command: $e');
      if (e is ServerException) rethrow;
      if (e is UnauthorizedException) rethrow;
      throw NetworkException();
    }
  }
}
