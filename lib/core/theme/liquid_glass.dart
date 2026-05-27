import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// iOS 26 "Liquid Glass" surface — frosted blur + translucent fill + subtle
/// inner highlight border. Wrap any rectangular content in this to make it
/// feel like a glass panel floating above the background.
///
/// Example:
/// ```dart
/// LiquidGlass(
///   radius: 24,
///   child: Padding(
///     padding: EdgeInsets.all(16),
///     child: Text('Floating panel'),
///   ),
/// )
/// ```
class LiquidGlass extends StatelessWidget {
  /// Corner radius. Defaults to 20 — matches Apple's iOS 26 sheet radius.
  final double radius;

  /// Blur sigma applied behind the surface. Higher = more frosted.
  final double blur;

  /// Translucent fill color. Defaults to [AppColors.glassFill].
  final Color? fillColor;

  /// Optional 1-px inner light border. Defaults to [AppColors.glassBorder].
  final Color? borderColor;

  /// Drop shadow opacity (0–1). Default soft.
  final double shadowOpacity;

  final Widget child;

  const LiquidGlass({
    super.key,
    required this.child,
    this.radius = 20,
    this.blur = 24,
    this.fillColor,
    this.borderColor,
    this.shadowOpacity = 0.10,
  });

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        borderRadius: br,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withAlpha((shadowOpacity * 255).toInt()),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: fillColor ?? AppColors.glassFill,
              borderRadius: br,
              border: Border.all(
                color: borderColor ?? AppColors.glassBorder,
                width: 1,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withAlpha(40),
                  Colors.white.withAlpha(0),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
