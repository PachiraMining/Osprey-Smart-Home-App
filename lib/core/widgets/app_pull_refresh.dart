import 'package:flutter/material.dart';

import 'bulb_refresh.dart';

/// Pull-to-refresh dùng chung cho cả app: hiệu ứng bóng đèn vẽ dần theo lực kéo
/// ([BulbRefresh]), chỉnh một lần ở đây để mọi màn kéo-làm-mới giống nhau.
class AppPullRefresh extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const AppPullRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Giữ nguyên màu xám mặc định của BulbRefresh — đúng như bản đo từ các
    // frame gốc. Đổi sang màu thương hiệu chỉ cần thêm `color:` ở đây.
    return BulbRefresh(
      onRefresh: onRefresh,
      child: child,
    );
  }
}
