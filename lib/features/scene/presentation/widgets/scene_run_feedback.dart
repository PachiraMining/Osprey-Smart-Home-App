import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';

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
  AppPopup.loading(context, title: AppL10n.of(context).running, message: sceneName);

  final ok = await run();
  if (!context.mounted) return;

  // Đóng popup loading trước khi mở popup kết quả.
  Navigator.of(context, rootNavigator: true).pop();

  if (ok) {
    AppPopup.success(
      context,
      title: AppL10n.of(context).done,
      message: AppL10n.of(context).sceneExecuted(sceneName),
    );
  } else {
    AppPopup.error(
      context,
      title: AppL10n.of(context).failed,
      message: AppL10n.of(context).couldNotRunScene(sceneName),
    );
  }
}
