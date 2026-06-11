import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:home_widget/home_widget.dart';

/// Cầu nối dữ liệu app → home-screen widget (iOS WidgetKit + Android
/// AppWidget) qua package `home_widget`.
///
/// Keys chia sẻ (đọc bởi Swift widget / Kotlin provider / Dart callback):
///  - `widget_devices`       : JSON list [{id,name,online}] — iOS dùng cho
///                             menu Edit Widget chọn thiết bị
///  - `widget_device_id`     : deviceId mặc định (fallback khi chưa chọn)
///  - `widget_device_name`   : tên hiển thị
///  - `widget_device_online` : bool online
///  - `widget_jwt`           : JWT (CHỈ iOS — AppIntent của extension gọi
///                             API trực tiếp, không đọc được Keychain của
///                             app; Android dùng secure storage nên không lưu)
///  - `widget_last_action`   : open/close/stop gần nhất (widget hiển thị)
///  - `widget_error`         : no_auth / auth_expired / network / http_xxx
class HomeWidgetService {
  static const String appGroupId = 'group.io.dracaena.curtainai';

  /// Tên kind của widget iOS (struct Widget trong extension).
  static const String _iosWidgetKind = 'OspreyCurtainWidget';

  /// Tên class provider Android.
  static const String _androidProvider = 'OspreyWidgetProvider';

  Future<void> init() async {
    try {
      if (Platform.isIOS) {
        await HomeWidget.setAppGroupId(appGroupId);
      }
    } catch (e) {
      log('HomeWidgetService.init failed: $e', name: 'widget');
    }
  }

  /// Đẩy JWT cho widget iOS (extension gọi API bằng token này).
  /// Token hết hạn → widget báo "mở app"; mở app lại là tự đẩy token mới.
  Future<void> pushAuthToken(String? token) async {
    if (!Platform.isIOS) return; // Android đọc secure storage trực tiếp
    try {
      await HomeWidget.saveWidgetData<String>('widget_jwt', token ?? '');
      if (token == null || token.isEmpty) {
        await HomeWidget.saveWidgetData<String>('widget_error', 'no_auth');
      } else {
        await HomeWidget.saveWidgetData<String>('widget_error', '');
      }
      await update();
    } catch (e) {
      log('pushAuthToken failed: $e', name: 'widget');
    }
  }

  /// Đẩy danh sách thiết bị của home lên widget.
  ///
  /// Thiết bị đầu tiên là mặc định; iOS cho phép long-press → Edit Widget
  /// để chọn thiết bị khác trong danh sách này.
  Future<void> pushDevices(List<WidgetDevice> devices) async {
    if (devices.isEmpty) return;
    try {
      await HomeWidget.saveWidgetData<String>(
        'widget_devices',
        jsonEncode(devices.map((d) => d.toJson()).toList()),
      );
      final primary = devices.first;
      await HomeWidget.saveWidgetData<String>('widget_device_id', primary.id);
      await HomeWidget.saveWidgetData<String>(
          'widget_device_name', primary.name);
      await HomeWidget.saveWidgetData<bool>(
          'widget_device_online', primary.isOnline);
      await update();
    } catch (e) {
      log('pushDevices failed: $e', name: 'widget');
    }
  }

  /// Yêu cầu hệ điều hành vẽ lại widget.
  Future<void> update() async {
    try {
      await HomeWidget.updateWidget(
        iOSName: _iosWidgetKind,
        androidName: _androidProvider,
      );
    } catch (e) {
      log('updateWidget failed: $e', name: 'widget');
    }
  }
}

/// Thiết bị hiển thị trong menu chọn của widget.
class WidgetDevice {
  const WidgetDevice({
    required this.id,
    required this.name,
    required this.isOnline,
  });

  final String id;
  final String name;
  final bool isOnline;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'online': isOnline,
      };
}
