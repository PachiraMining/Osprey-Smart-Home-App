import 'dart:convert';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:home_widget/home_widget.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// Callback chạy NỀN khi bấm nút trên widget Android (home_widget spin một
/// Flutter engine headless trong process app → đọc được secure storage,
/// JWT luôn tươi — khác iOS phải mirror token qua App Group).
///
/// URI từ nút bấm: `ospreywidget://control?action=open|close|stop`.
@pragma('vm:entry-point')
Future<void> ospreyWidgetCallback(Uri? uri) async {
  if (uri == null || uri.host != 'control') return;
  final action = uri.queryParameters['action'];
  if (action == null || !{'open', 'close', 'stop'}.contains(action)) return;

  WidgetsFlutterBinding.ensureInitialized();

  Future<void> fail(String code) async {
    await HomeWidget.saveWidgetData<String>('widget_error', code);
    await HomeWidget.updateWidget(androidName: 'OspreyWidgetProvider');
  }

  try {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');
    final deviceId =
        await HomeWidget.getWidgetData<String>('widget_device_id');

    if (token == null || token.isEmpty) return fail('no_auth');
    if (deviceId == null || deviceId.isEmpty) return fail('no_device');

    final response = await http
        .post(
          Uri.parse(
            '${AppConfig.thingsboardBaseUrl}'
            '/api/smarthome/devices/$deviceId/commands',
          ),
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
            'X-Authorization': 'Bearer $token',
          },
          body: jsonEncode({'dpId': 1, 'value': action}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      await HomeWidget.saveWidgetData<String>('widget_last_action', action);
      await HomeWidget.saveWidgetData<String>('widget_error', '');
    } else if (response.statusCode == 401) {
      await HomeWidget.saveWidgetData<String>('widget_error', 'auth_expired');
    } else {
      await HomeWidget.saveWidgetData<String>(
          'widget_error', 'http_${response.statusCode}');
    }
  } catch (e) {
    log('widget command failed: $e', name: 'widget');
    await HomeWidget.saveWidgetData<String>('widget_error', 'network');
  }
  await HomeWidget.updateWidget(androidName: 'OspreyWidgetProvider');
}
