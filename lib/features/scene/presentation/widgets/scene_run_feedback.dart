import 'package:flutter/material.dart';

import '../../../../core/widgets/app_popup.dart';

/// Luồng popup DÙNG CHUNG khi chạy một scene: loading "Running" → "Done" hoặc
/// báo lỗi.
///
/// Tách ra để pill ở Home tab và trang scene-của-thiết-bị hiện y hệt nhau; sửa
/// một chỗ là cả hai đổi theo.
///
/// [run] trả `true` khi scene chạy thành công.
Future<void> showSceneRunFeedback({
  required BuildContext context,
  required String sceneName,
  required Future<bool> Function() run,
}) async {
  AppPopup.loading(context, title: 'Running', message: sceneName);

  final ok = await run();
  if (!context.mounted) return;

  // Đóng popup loading trước khi mở popup kết quả.
  Navigator.of(context, rootNavigator: true).pop();

  if (ok) {
    AppPopup.success(
      context,
      title: 'Done',
      message: '"$sceneName" executed',
    );
  } else {
    AppPopup.error(
      context,
      title: 'Failed',
      message: 'Could not run "$sceneName". Please try again.',
    );
  }
}
