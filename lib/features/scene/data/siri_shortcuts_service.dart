import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

/// Cầu nối tới Siri Shortcuts phía iOS (`ios/Runner/Siri/`).
///
/// Android không có Siri nên mọi thứ trả về rỗng và UI tự ẩn.
class SiriShortcutsService {
  static const _channel = MethodChannel('osprey/siri');

  const SiriShortcutsService();

  /// Chỉ iOS mới có Siri; kiểm tra trước khi vẽ nút "Add to Siri".
  bool get isSupported => Platform.isIOS;

  /// `{sceneId: câu lệnh đã gán}` — scene không có trong map là chưa thêm.
  Future<Map<String, String>> listShortcuts() async {
    if (!isSupported) return const {};
    try {
      final raw = await _channel.invokeMapMethod<String, String>('listShortcuts');
      return raw ?? const {};
    } on PlatformException catch (e) {
      dev.log('listShortcuts failed: ${e.message}', name: 'siri');
      return const {};
    } on MissingPluginException {
      return const {};
    }
  }

  /// Mở sheet hệ thống để thêm (hoặc sửa) câu lệnh cho scene.
  ///
  /// Trả câu lệnh sau khi user lưu; `null` nếu user huỷ/xoá. Ném
  /// [SiriUnavailableException] khi phía iOS không phản hồi — sheet không mở
  /// được thì UI phải BÁO, không im lặng như trước.
  Future<String?> presentAddToSiri({
    required String sceneId,
    required String sceneName,
  }) async {
    if (!isSupported) throw const SiriUnavailableException('Siri is iOS-only.');
    try {
      return await _channel.invokeMethod<String>('presentAddToSiri', {
        'sceneId': sceneId,
        'sceneName': sceneName,
      });
    } on PlatformException catch (e) {
      dev.log('presentAddToSiri failed: ${e.message}', name: 'siri');
      throw SiriUnavailableException(e.message ?? 'Could not open Siri.');
    } on MissingPluginException {
      dev.log('siri channel not registered', name: 'siri');
      throw const SiriUnavailableException(
        'Siri is not available in this build.',
      );
    }
  }
}

/// Chẩn đoán đọc từ App Group — Shortcuts chỉ báo "An unknown error occurred"
/// nên cần biết handler hỏng ở bước nào.
class SiriDiagnostics {
  final bool hasToken;
  final String baseUrl;
  final String lastResult;

  const SiriDiagnostics({
    required this.hasToken,
    required this.baseUrl,
    required this.lastResult,
  });

  /// `null` khi chưa có gì đáng báo (đã có token và chưa chạy lần nào).
  String? get summary {
    if (!hasToken) return 'Not signed in for Siri — reopen the app once.';
    if (lastResult.isEmpty || lastResult == 'ok') return null;
    return 'Last Siri run: $lastResult';
  }
}

extension SiriDiagnosticsReader on SiriShortcutsService {
  Future<SiriDiagnostics> diagnostics() async {
    if (!isSupported) {
      return const SiriDiagnostics(hasToken: false, baseUrl: '', lastResult: '');
    }
    try {
      final jwt = await HomeWidget.getWidgetData<String>('widget_jwt');
      final base = await HomeWidget.getWidgetData<String>('api_base_url');
      final last = await HomeWidget.getWidgetData<String>('siri_last_result');
      return SiriDiagnostics(
        hasToken: jwt != null && jwt.isNotEmpty,
        baseUrl: base ?? '',
        lastResult: last ?? '',
      );
    } catch (e) {
      dev.log('diagnostics failed: $e', name: 'siri');
      return const SiriDiagnostics(hasToken: true, baseUrl: '', lastResult: '');
    }
  }
}

/// Phía iOS không mở được sheet Siri (channel chưa đăng ký, hoặc lỗi hệ thống).
class SiriUnavailableException implements Exception {
  final String message;
  const SiriUnavailableException(this.message);

  @override
  String toString() => message;
}
