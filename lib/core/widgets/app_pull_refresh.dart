import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../theme/app_colors.dart';

/// App-wide pull-to-refresh: the liquid effect from liquid_pull_to_refresh,
/// tuned once here so every screen refreshes with the same look.
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
    return LiquidPullToRefresh(
      onRefresh: onRefresh,
      color: AppColors.primary,
      backgroundColor: Colors.white,
      height: 80,
      animSpeedFactor: 2.5,
      // Keep the list fully opaque while pulling — the fade transition makes
      // content flash on long lists.
      showChildOpacityTransition: false,
      child: child,
    );
  }
}
