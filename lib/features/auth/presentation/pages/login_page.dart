import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/social_login_service.dart';
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
import 'sign_up_page.dart';

/// Màn đăng nhập. Mọi trạng thái (loading/lỗi) hiển thị inline — không
/// dialog chặn màn; hỗ trợ autofill + submit từ bàn phím cho mượt.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool agreePolicy = false;
  bool obscurePassword = true;
  bool _agreementHighlight = false;
  String? _emailError;
  String? _passwordError;
  String? _serverError;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final _agreementShakeKey = GlobalKey<ShakeableState>();

  String? _googleProviderUrl;
  String? _appleProviderUrl;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    try {
      final providers =
          await sl<SocialLoginService>().fetchAvailableProviders();
      if (!mounted) return;
      final google = providers
          .where((p) => p.name.toLowerCase().contains('google'))
          .firstOrNull;
      final apple = providers
          .where((p) => p.name.toLowerCase().contains('apple'))
          .firstOrNull;
      setState(() {
        _googleProviderUrl = google?.authorizationUrl;
        _appleProviderUrl = apple?.authorizationUrl;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    final email = usernameController.text.trim();
    final password = passwordController.text.trim();
    setState(() {
      _emailError = email.isEmpty ? 'Enter your email or username' : null;
      _passwordError = password.isEmpty ? 'Enter your password' : null;
      _serverError = null;
    });
    if (_emailError != null || _passwordError != null) return;
    if (!agreePolicy) {
      HapticFeedback.mediumImpact();
      setState(() => _agreementHighlight = true);
      _agreementShakeKey.currentState?.shake();
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(LoginRequested(email, password));
  }

  void _openSignUp() {
    setState(() => _serverError = null);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SignUpPage(initialEmail: usernameController.text.trim()),
      ),
    );
  }

  void _onSocialTap(String? providerUrl, String name) {
    if (providerUrl != null) {
      setState(() => _serverError = null);
      context.read<AuthBloc>().add(SocialLoginRequested(providerUrl));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name sign-in is not available yet.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primaryDark,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // AuthBloc dùng chung (signup cũng đăng nhập qua nó) — chỉ phản ứng
        // khi màn này đang trên cùng để tránh điều hướng/báo lỗi trùng.
        if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
        if (state is AuthSuccess) {
          TextInput.finishAutofillContext(); // gợi ý lưu mật khẩu
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false);
        }
        if (state is AuthFailure) {
          HapticFeedback.mediumImpact();
          setState(() => _serverError = state.message);
        }
      },
      builder: (context, state) {
        final busy = state is AuthLoading;
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
                    const SizedBox(height: 16),
                    AuthBackButton(
                      onPressed: busy ? null : () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 36),
                    Text(
                      'Welcome',
                      style: AppTypography.displayMedium
                          .copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to your osprey.life account.',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 28),
                    AuthField(
                      label: 'Email or username',
                      controller: usernameController,
                      hintText: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.email,
                        AutofillHints.username,
                      ],
                      enabled: !busy,
                      errorText: _emailError,
                      onChanged: (_) {
                        if (_emailError != null || _serverError != null) {
                          setState(() {
                            _emailError = null;
                            _serverError = null;
                          });
                        }
                      },
                      prefix: const Icon(
                        Icons.alternate_email_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AuthField(
                      label: 'Password',
                      controller: passwordController,
                      hintText: 'Enter your password',
                      obscureText: obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      enabled: !busy,
                      errorText: _passwordError,
                      onChanged: (_) {
                        if (_passwordError != null || _serverError != null) {
                          setState(() {
                            _passwordError = null;
                            _serverError = null;
                          });
                        }
                      },
                      onSubmitted: (_) => _signIn(),
                      prefix: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      suffix: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () => setState(() {
                          obscurePassword = !obscurePassword;
                        }),
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
                      label: 'Sign in',
                      busy: busy,
                      onPressed: busy ? null : _signIn,
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: TextButton(
                        onPressed: busy ? null : _openSignUp,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'New to osprey.life? ',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextSpan(
                                text: 'Create one',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: TextButton(
                        onPressed: busy ? null : _showResetPasswordSheet,
                        child: Text(
                          'Forgot password?',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Social login — ẩn tới khi server cấu hình OAuth provider
                    if (_googleProviderUrl != null ||
                        _appleProviderUrl != null) ...[
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.divider)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or continue with',
                              style: AppTypography.labelSmall
                                  .copyWith(color: AppColors.textMuted),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.divider)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_googleProviderUrl != null)
                            _SocialIconButton(
                              onTap: busy
                                  ? null
                                  : () => _onSocialTap(
                                      _googleProviderUrl, 'Google'),
                              child: const Text(
                                'G',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4285F4),
                                ),
                              ),
                            ),
                          if (_googleProviderUrl != null &&
                              _appleProviderUrl != null)
                            const SizedBox(width: 16),
                          if (_appleProviderUrl != null)
                            _SocialIconButton(
                              bgColor: Colors.black,
                              onTap: busy
                                  ? null
                                  : () =>
                                      _onSocialTap(_appleProviderUrl, 'Apple'),
                              child: const Icon(Icons.apple,
                                  color: Colors.white, size: 28),
                            ),
                        ],
                      ),
                    ],
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

  // ─── Quên mật khẩu ──────────────────────────────────────────
  void _showResetPasswordSheet() {
    final emailCtrl =
        TextEditingController(text: usernameController.text.trim());
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
        child: _ResetPasswordSheet(emailController: emailCtrl),
      ),
    ).whenComplete(emailCtrl.dispose);
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

/// Bottom sheet đặt lại mật khẩu: nhập email → gửi link reset.
class _ResetPasswordSheet extends StatefulWidget {
  final TextEditingController emailController;
  const _ResetPasswordSheet({required this.emailController});

  @override
  State<_ResetPasswordSheet> createState() => _ResetPasswordSheetState();
}

class _ResetPasswordSheetState extends State<_ResetPasswordSheet> {
  bool _sending = false;
  bool _sent = false;
  String? _error;

  Future<void> _submit() async {
    final email = widget.emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await sl<AuthRemoteDataSource>().requestPasswordReset(email);
      if (!mounted) return;
      setState(() {
        _sending = false;
        _sent = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = authErrorText(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: _sent ? _sentView() : _formView(),
        ),
      ),
    );
  }

  Widget _formView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reset your password',
          style: AppTypography.displayMedium.copyWith(
            fontSize: 22,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Enter your account email and we'll send you a reset link.",
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        AuthField(
          label: 'Email address',
          controller: widget.emailController,
          hintText: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          enabled: !_sending,
          errorText: _error,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: (_) => _submit(),
          prefix: const Icon(Icons.alternate_email_rounded,
              color: AppColors.textMuted, size: 20),
        ),
        const SizedBox(height: 20),
        AuthPrimaryButton(
          label: 'Send reset link',
          busy: _sending,
          onPressed: _sending ? null : _submit,
        ),
      ],
    );
  }

  Widget _sentView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppColors.primarySubtle,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_outlined,
              size: 36, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Text(
          'Check your inbox',
          style: AppTypography.displayMedium.copyWith(
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'If an account exists for ${widget.emailController.text.trim()}, '
          'a password reset link is on its way.',
          textAlign: TextAlign.center,
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        AuthPrimaryButton(
          label: 'Done',
          busy: false,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final Widget child;
  final Color bgColor;
  final VoidCallback? onTap;

  const _SocialIconButton({
    required this.child,
    this.bgColor = AppColors.surface,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap != null ? 1.0 : 0.4,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: bgColor == AppColors.surface
                ? Border.all(color: AppColors.border)
                : null,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
