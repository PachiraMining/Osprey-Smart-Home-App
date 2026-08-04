import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_surfaces.dart';

/// Custom center popup replacing QuickAlert across the app.
///
/// Three variants share one look (white rounded card, animated icon, title +
/// optional message):
///   • [AppPopup.loading] — spinner; stays until the caller pops it
///     (`Navigator.of(context, rootNavigator: true).pop()`).
///   • [AppPopup.success] / [AppPopup.error] — icon + auto-dismiss.
class AppPopup {
  AppPopup._();

  static Future<void> loading(
    BuildContext context, {
    required String title,
    String? message,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(90),
      builder: (_) => _PopupCard(
        variant: _PopupVariant.loading,
        title: title,
        message: message,
      ),
    );
  }

  static Future<void> success(
    BuildContext context, {
    required String title,
    String? message,
    Duration duration = const Duration(milliseconds: 1100),
  }) {
    return _autoClose(context, _PopupVariant.success, title, message, duration);
  }

  static Future<void> error(
    BuildContext context, {
    required String title,
    String? message,
    Duration duration = const Duration(milliseconds: 1800),
  }) {
    return _autoClose(context, _PopupVariant.error, title, message, duration);
  }

  static Future<void> _autoClose(
    BuildContext context,
    _PopupVariant variant,
    String title,
    String? message,
    Duration duration,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withAlpha(90),
      builder: (dialogContext) {
        // Auto-dismiss after [duration] unless already closed.
        Future.delayed(duration, () {
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
        });
        return _PopupCard(variant: variant, title: title, message: message);
      },
    );
  }
}

enum _PopupVariant { loading, success, error }

class _PopupCard extends StatelessWidget {
  final _PopupVariant variant;
  final String title;
  final String? message;

  const _PopupCard({
    required this.variant,
    required this.title,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.85, end: 1),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) => Transform.scale(
          scale: scale,
          child: Opacity(opacity: scale.clamp(0.0, 1.0), child: child),
        ),
        child: Container(
          width: 180,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: context.surfaces.card,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(38),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Icon(variant: variant),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (message != null && message!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  final _PopupVariant variant;
  const _Icon({required this.variant});

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case _PopupVariant.loading:
        return const SizedBox(
          width: 46,
          height: 46,
          child: CircularProgressIndicator(
            strokeWidth: 3.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        );
      case _PopupVariant.success:
        return _badge(AppColors.success, Icons.check_rounded);
      case _PopupVariant.error:
        return _badge(const Color(0xFFE05252), Icons.close_rounded);
    }
  }

  Widget _badge(Color color, IconData icon) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 34),
    );
  }
}
