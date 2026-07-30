import 'package:flutter/material.dart';

import '../../l10n/gen/app_l10n.dart';

import '../theme/app_colors.dart';

/// Custom-styled replacements for the app's stock [AlertDialog]s.
///
///   • [AppDialog.confirm] — title + message + Cancel/Confirm. Returns `true`
///     when confirmed. Set [destructive] for a red confirm button.
///   • [AppDialog.prompt]  — title + text field + Cancel/Confirm. Returns the
///     trimmed text, or `null` if cancelled/empty.
class AppDialog {
  AppDialog._();

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String? message,
    String? confirmText,
    String? cancelText,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withAlpha(90),
      builder: (ctx) => _DialogFrame(
        title: title,
        content: message == null
            ? null
            : Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              ),
        cancelText: cancelText ?? AppL10n.of(context).cancel,
        confirmText: confirmText ?? AppL10n.of(context).ok,
        destructive: destructive,
        onConfirm: () => Navigator.pop(ctx, true),
        onCancel: () => Navigator.pop(ctx, false),
      ),
    );
    return result ?? false;
  }

  /// Single-button acknowledgement dialog (no Cancel).
  static Future<void> alert(
    BuildContext context, {
    required String title,
    String? message,
    String? buttonText,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withAlpha(90),
      builder: (ctx) => _DialogFrame(
        title: title,
        content: message == null
            ? null
            : Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              ),
        cancelText: '',
        confirmText: buttonText ?? AppL10n.of(context).ok,
        destructive: false,
        singleButton: true,
        onConfirm: () => Navigator.pop(ctx),
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  /// Confirm dialog with a message AND an (optional) text field — e.g. a
  /// destructive action that also collects a reason. Returns `(ok, text)`;
  /// `ok` is false on cancel, `text` is the trimmed input or null when empty.
  static Future<({bool ok, String? text})> confirmWithInput(
    BuildContext context, {
    required String title,
    String? message,
    Color? messageColor,
    String? hintText,
    String? confirmText,
    String? cancelText,
    bool destructive = false,
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<({bool ok, String? text})>(
      context: context,
      barrierColor: Colors.black.withAlpha(90),
      builder: (ctx) => _DialogFrame(
        title: title,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message != null)
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: messageColor ?? AppColors.textSecondary,
                ),
              ),
            if (message != null) const SizedBox(height: 14),
            TextField(
              controller: controller,
              maxLines: 2,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceMuted,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        cancelText: cancelText ?? AppL10n.of(context).cancel,
        confirmText: confirmText ?? AppL10n.of(context).ok,
        destructive: destructive,
        onConfirm: () {
          final t = controller.text.trim();
          Navigator.pop(ctx, (ok: true, text: t.isEmpty ? null : t));
        },
        onCancel: () => Navigator.pop(ctx, (ok: false, text: null)),
      ),
    );
    return result ?? (ok: false, text: null);
  }

  static Future<String?> prompt(
    BuildContext context, {
    required String title,
    String? hintText,
    String? initialValue,
    String? confirmText,
    String? cancelText,
  }) {
    final controller = TextEditingController(text: initialValue);
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black.withAlpha(90),
      builder: (ctx) {
        void submit() {
          final v = controller.text.trim();
          Navigator.pop(ctx, v.isEmpty ? null : v);
        }

        return _DialogFrame(
          title: title,
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => submit(),
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surfaceMuted,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          cancelText: cancelText ?? AppL10n.of(context).cancel,
          confirmText: confirmText ?? AppL10n.of(context).ok,
          destructive: false,
          onConfirm: submit,
          onCancel: () => Navigator.pop(ctx, null),
        );
      },
    );
  }
}

class _DialogFrame extends StatelessWidget {
  final String title;
  final Widget? content;
  final String cancelText;
  final String confirmText;
  final bool destructive;
  final bool singleButton;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _DialogFrame({
    required this.title,
    required this.content,
    required this.cancelText,
    required this.confirmText,
    required this.destructive,
    required this.onConfirm,
    required this.onCancel,
    this.singleButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final confirmColor = destructive ? const Color(0xFFE05252) : AppColors.primary;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.9, end: 1),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        builder: (context, s, child) =>
            Transform.scale(scale: s, child: Opacity(opacity: s.clamp(0, 1), child: child)),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
          decoration: BoxDecoration(
            color: Colors.white,
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
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (content != null) ...[
                const SizedBox(height: 12),
                content!,
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  if (!singleButton) ...[
                    Expanded(
                      child: TextButton(
                        onPressed: onCancel,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: AppColors.surfaceMuted,
                        ),
                        child: Text(
                          cancelText,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: TextButton(
                      onPressed: onConfirm,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: confirmColor,
                      ),
                      child: Text(
                        confirmText,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
