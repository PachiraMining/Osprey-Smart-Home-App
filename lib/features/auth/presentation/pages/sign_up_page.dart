import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../utils/auth_error_text.dart';
import '../widgets/auth_form_widgets.dart';

/// Đăng ký kiểu Tuya, 2 bước trên cùng 1 màn:
///  1. email + mật khẩu → gửi mã xác thực 6 số (hạn 5 phút)
///  2. nhập mã → tạo tài khoản (kích hoạt ngay) → tự đăng nhập → vào Home.
class SignUpPage extends StatefulWidget {
  /// Email gõ sẵn bên màn login (nếu có) — đỡ phải nhập lại.
  final String? initialEmail;
  const SignUpPage({super.key, this.initialEmail});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

enum _Step { account, verify }

class _SignUpPageState extends State<SignUpPage> {
  static const int _resendCooldownSeconds = 60;
  static final RegExp _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  _Step _step = _Step.account;
  bool agreePolicy = false;
  bool _obscurePassword = true;
  bool _sending = false; // gửi mã / tạo tài khoản (call trực tiếp datasource)
  String? _emailError;
  String? _passwordError;
  String? _codeError;
  String? _serverError;
  bool _agreementHighlight = false;
  bool _codeAutoSubmitted = false;

  Timer? _resendTimer;
  int _resendIn = 0;

  late final TextEditingController emailController =
      TextEditingController(text: widget.initialEmail ?? '');
  final passwordController = TextEditingController();
  final codeController = TextEditingController();
  final _agreementShakeKey = GlobalKey<ShakeableState>();

  @override
  void dispose() {
    _resendTimer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    codeController.dispose();
    super.dispose();
  }

  // ─── Step 1: gửi mã ─────────────────────────────────────────
  bool _validateAccountStep() {
    final email = emailController.text.trim();
    final password = passwordController.text;
    setState(() {
      _emailError = email.isEmpty
          ? 'Enter your email address'
          : (!_emailRegex.hasMatch(email)
              ? 'Enter a valid email address'
              : null);
      _passwordError = password.isEmpty
          ? 'Enter a password'
          : (password.length < 6 ? 'At least 6 characters' : null);
      _serverError = null;
    });
    if (_emailError != null || _passwordError != null) return false;
    if (!agreePolicy) {
      HapticFeedback.mediumImpact();
      setState(() => _agreementHighlight = true);
      _agreementShakeKey.currentState?.shake();
      return false;
    }
    return true;
  }

  Future<void> _sendCode({bool resend = false}) async {
    if (_sending) return;
    if (!resend && !_validateAccountStep()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _sending = true;
      _serverError = null;
      _codeError = null;
    });
    try {
      await sl<AuthRemoteDataSource>()
          .sendSignupVerificationCode(emailController.text.trim());
      if (!mounted) return;
      codeController.clear();
      _codeAutoSubmitted = false;
      _startResendCooldown();
      setState(() {
        _sending = false;
        _step = _Step.verify;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _serverError = authErrorText(e);
      });
    }
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    _resendIn = _resendCooldownSeconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _resendIn--);
      if (_resendIn <= 0) t.cancel();
    });
  }

  // ─── Step 2: tạo tài khoản ──────────────────────────────────
  Future<void> _createAccount() async {
    if (_sending) return;
    final code = codeController.text.trim();
    if (code.length != 6) {
      setState(() => _codeError = 'Enter the 6-digit code');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _sending = true;
      _codeError = null;
      _serverError = null;
    });
    final email = emailController.text.trim();
    final password = passwordController.text;
    try {
      final session = await sl<AuthRemoteDataSource>().signup(
        email: email,
        verificationCode: code,
        password: password,
      );
      if (!mounted) return;
      setState(() => _sending = false);
      // Signup trả JWT ngay — lưu phiên luôn, AuthSuccess sẽ điều hướng.
      context.read<AuthBloc>().add(SessionTokensReceived(
            token: session.token,
            refreshToken: session.refreshToken,
          ));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _codeAutoSubmitted = false;
        _serverError = authErrorText(e);
      });
    }
  }

  // ─── UI ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Chỉ phản ứng khi màn này đang trên cùng (AuthBloc dùng chung).
        if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
        if (state is AuthSuccess) {
          TextInput.finishAutofillContext(); // gợi ý lưu mật khẩu
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false);
        }
        if (state is AuthFailure) {
          // Hiếm: tạo tài khoản OK nhưng auto-login lỗi → về màn login.
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Account created — please sign in.'),
            backgroundColor: AppColors.primaryDark,
            behavior: SnackBarBehavior.floating,
          ));
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final busy = _sending || state is AuthLoading;
        return Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    AuthBackButton(
                      onPressed: busy
                          ? null
                          : () {
                              if (_step == _Step.verify) {
                                setState(() {
                                  _step = _Step.account;
                                  _serverError = null;
                                });
                              } else {
                                Navigator.pop(context);
                              }
                            },
                    ),
                    const SizedBox(height: 36),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.06, 0),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: _step == _Step.account
                          ? _accountStep(busy)
                          : _verifyStep(busy),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Bước 1 ─────────────────────────────────────────────────
  Widget _accountStep(bool busy) {
    return Column(
      key: const ValueKey('account'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create your account',
          style: AppTypography.displayMedium
              .copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 28),
        AuthField(
          label: 'Email address',
          controller: emailController,
          hintText: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          enabled: !busy,
          errorText: _emailError,
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
          prefix: const Icon(Icons.alternate_email_rounded,
              color: AppColors.textMuted, size: 20),
        ),
        const SizedBox(height: 16),
        AuthField(
          label: 'Password',
          controller: passwordController,
          hintText: 'At least 6 characters',
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          enabled: !busy,
          errorText: _passwordError,
          onChanged: (_) {
            if (_passwordError != null) {
              setState(() => _passwordError = null);
            }
          },
          onSubmitted: (_) => _sendCode(),
          prefix: const Icon(Icons.lock_outline_rounded,
              color: AppColors.textMuted, size: 20),
          suffix: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textMuted,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 22),
        Shakeable(
          key: _agreementShakeKey,
          child: AgreementRow(
            value: agreePolicy,
            highlight: _agreementHighlight,
            onChanged: (v) => setState(() {
              agreePolicy = v;
              if (v) _agreementHighlight = false;
            }),
          ),
        ),
        AuthErrorBanner(message: _serverError),
        const SizedBox(height: 22),
        AuthPrimaryButton(
          label: 'Send verification code',
          busy: _sending,
          onPressed: busy ? null : _sendCode,
        ),
      ],
    );
  }

  // ─── Bước 2 ─────────────────────────────────────────────────
  Widget _verifyStep(bool busy) {
    return Column(
      key: const ValueKey('verify'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Check your email',
          style: AppTypography.displayMedium
              .copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'We sent a 6-digit code to ',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              TextSpan(
                text: emailController.text.trim(),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: '. The code expires in 5 minutes.',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _CodeField(
          controller: codeController,
          enabled: !busy,
          errorText: _codeError,
          onChanged: (value) {
            if (_codeError != null) setState(() => _codeError = null);
            // Đủ 6 số → tự submit một lần, khỏi bấm nút.
            if (value.length == 6 && !_codeAutoSubmitted && !busy) {
              _codeAutoSubmitted = true;
              _createAccount();
            }
          },
        ),
        AuthErrorBanner(message: _serverError),
        const SizedBox(height: 22),
        AuthPrimaryButton(
          label: 'Create account',
          busy: busy,
          onPressed: busy ? null : _createAccount,
        ),
        const SizedBox(height: 14),
        Center(
          child: TextButton(
            onPressed: (busy || _resendIn > 0)
                ? null
                : () => _sendCode(resend: true),
            child: Text(
              _resendIn > 0 ? 'Resend code in ${_resendIn}s' : 'Resend code',
              style: AppTypography.labelMedium.copyWith(
                color: _resendIn > 0 ? AppColors.textMuted : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

/// Ô nhập mã 6 số — to, giãn chữ, bàn phím số, hỗ trợ autofill OTP.
class _CodeField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final String? errorText;
  final ValueChanged<String> onChanged;
  const _CodeField({
    required this.controller,
    required this.enabled,
    required this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: errorText != null ? AppColors.error : AppColors.border,
              width: errorText != null ? 1.6 : 1.2,
            ),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            autofocus: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            autofillHints: const [AutofillHints.oneTimeCode],
            onChanged: onChanged,
            cursorColor: AppColors.primary,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '······',
              hintStyle: TextStyle(
                fontSize: 28,
                letterSpacing: 14,
                color: AppColors.textMuted.withAlpha(120),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Text(
              errorText!,
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}
