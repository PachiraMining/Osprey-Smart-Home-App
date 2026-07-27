// lib/features/device/data/datasources/device_control_data_source.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';

abstract class DeviceControlDataSource {
  Future<void> sendCommand(String deviceId, String command);

  /// Send an arbitrary DP write (e.g. dpId 5 = Motor Direction), for controls
  /// the string-based [sendCommand] doesn't cover.
  Future<void> sendDp(String deviceId, int dpId, dynamic value);

  /// Read live device status → map of DP `code` → value
  /// (control, percent_state, control_back, work_state, battery_percentage…).
  Future<Map<String, dynamic>> getStatus(String deviceId);
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
      // DP-command API chuẩn (cùng đường với curtain page + home widget):
      //   dpId 1: 'open' | 'close' | 'stop'
      //   dpId 2: phần trăm vị trí 0–100
      // (Thay cho POST /api/rpc/oneway 'setRelayState' cũ — firmware Osprey
      // không xử lý RPC đó, nên các nút quick-control trước đây không ăn.)
      final percent = int.tryParse(command);
      final body = jsonEncode(
        percent != null
            ? {'dpId': 2, 'value': percent.clamp(0, 100)}
            : {'dpId': 1, 'value': command.toLowerCase()},
      );

      final response = await client.post(
        Uri.parse('$baseUrl${ApiEndpoints.deviceCommands(deviceId)}'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException(
          message: 'Failed to send command: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      if (e is UnauthorizedException) rethrow;
      throw NetworkException();
    }
  }

  @override
  Future<void> sendDp(String deviceId, int dpId, dynamic value) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl${ApiEndpoints.deviceCommands(deviceId)}'),
        headers: _headers,
        body: jsonEncode({'dpId': dpId, 'value': value}),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) return;
      if (response.statusCode == 401) throw UnauthorizedException();
      throw ServerException(
          message: 'Failed to send command: ${response.statusCode}');
    } catch (e) {
      if (e is ServerException) rethrow;
      if (e is UnauthorizedException) rethrow;
      throw NetworkException();
    }
  }

  @override
  Future<Map<String, dynamic>> getStatus(String deviceId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl${ApiEndpoints.deviceStatus(deviceId)}'),
        headers: _headers,
      );
      if (response.statusCode == 401) throw UnauthorizedException();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ServerException(
            message: 'Failed to read status: ${response.statusCode}');
      }
      // Response is a list of DP objects: [{dpId, code, value, ...}]. Fold into
      // a code → value map for easy consumption.
      final decoded = jsonDecode(response.body);
      final list = decoded is List ? decoded : const [];
      final out = <String, dynamic>{};
      for (final dp in list) {
        if (dp is Map && dp['code'] is String) {
          out[dp['code'] as String] = dp['value'];
        }
      }
      return out;
    } catch (e) {
      if (e is ServerException) rethrow;
      if (e is UnauthorizedException) rethrow;
      throw NetworkException();
    }
  }
}
