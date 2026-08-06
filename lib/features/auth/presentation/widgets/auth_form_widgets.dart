import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/gen/app_l10n.dart';
import '../../../../core/theme/app_surfaces.dart';

/// Nút back vuông bo góc dùng chung cho các màn auth.
class AuthBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const AuthBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: context.surfaces.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.surfaces.divider),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, size: 20),
        padding: EdgeInsets.zero,
        color: context.surfaces.textPrimary,
        onPressed: onPressed,
      ),
    );
  }
}

/// Checkbox đồng ý Privacy Policy + User Agreement; viền đỏ khi [highlight].
class AgreementRow extends StatelessWidget {
  final bool value;
  final bool highlight;
  final ValueChanged<bool> onChanged;
  const AgreementRow({
    super.key,
    required this.value,
    required this.onChanged,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = highlight ? AppColors.error : context.surfaces.border;
    final subtle = AppTypography.bodySmall
        .copyWith(color: context.surfaces.textSecondary);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AppColors.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            side: BorderSide(color: borderColor, width: 1.4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Wrap(
            children: [
              Text('I agree to the ', style: subtle),
              GestureDetector(
                onTap: () => launchUrl(Uri.parse(AppConfig.privacyPolicyUrl)),
                child: Text(
                  AppL10n.of(context).privacyPolicy,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(' and ', style: subtle),
              GestureDetector(
                onTap: () => launchUrl(Uri.parse(AppConfig.userAgreementUrl)),
                child: Text(
                  AppL10n.of(context).userAgreement,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text('.', style: subtle),
            ],
          ),
        ),
      ],
    );
  }
}

/// Nút chính: hiện spinner inline khi [busy] thay vì dialog chặn màn.
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool busy;
  final VoidCallback? onPressed;
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor:
              busy ? AppColors.primary : context.surfaces.surfaceMuted,
          foregroundColor: AppColors.textInverse,
          disabledForegroundColor: context.surfaces.textMuted,
          minimumSize: const Size(0, 56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: AppTypography.labelLarge.copyWith(
                    fontSize: 15,
                    color: AppColors.textInverse,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Banner lỗi inline — trượt mở/đóng mượt thay vì popup chặn thao tác.
class AuthErrorBanner extends StatelessWidget {
  final String? message;
  const AuthErrorBanner({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    // Nền đỏ 7% chìm hẳn trên nền đen — chế độ tối cần đậm hơn mới thấy.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillAlpha = isDark ? 46 : 18;
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: message == null
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(fillAlpha),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.error.withAlpha(70)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline,
                      size: 18, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.error,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Rung ngang nhẹ — nhắc nhở (vd checkbox điều khoản) thay vì popup.
class Shakeable extends StatefulWidget {
  final Widget child;
  const Shakeable({super.key, required this.child});

  @override
  State<Shakeable> createState() => ShakeableState();
}

class ShakeableState extends State<Shakeable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  void shake() => _controller.forward(from: 0);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        final t = _controller.value;
        final dx = math.sin(t * math.pi * 5) * 8 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}

/// Ô nhập có label, lỗi inline, autofill và viền đổi màu khi focus/lỗi.
class AuthField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final bool enabled;
  final String? errorText;
  final Widget? suffix;
  final Widget? prefix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.enabled = true,
    this.errorText,
    this.suffix,
    this.prefix,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? AppColors.error
        : _focused
            ? AppColors.primary
            : surfaces.border;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            widget.label,
            style: AppTypography.labelMedium.copyWith(
              color: hasError
                  ? AppColors.error
                  : _focused
                      ? AppColors.primary
                      : surfaces.textSecondary,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: surfaces.card,
            borderRadius: BorderRadius.circular(AppRadius.field),
            border: Border.all(
              color: borderColor,
              width: (_focused || hasError) ? 1.8 : 1.2,
            ),
            boxShadow: _focused && !hasError
                ? [
                    BoxShadow(
                      color: AppColors.shadowFocus,
                      blurRadius: 0,
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            autofillHints: widget.autofillHints,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            cursorColor: AppColors.primary,
            cursorWidth: 1.6,
            style:
                AppTypography.bodyLarge.copyWith(color: surfaces.textPrimary),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle:
                  AppTypography.bodyLarge.copyWith(color: surfaces.textMuted),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              prefixIcon: widget.prefix,
              suffixIcon: widget.suffix,
              filled: false,
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, top: 6),
            child: Text(
              widget.errorText!,
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}
