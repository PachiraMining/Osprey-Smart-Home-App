import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/auth/social_login_service.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool agreePolicy = false;
  bool obscurePassword = true;
  bool _isSignUpMode = false;
  bool _isLoadingDialogShowing = false;

  String? _googleProviderUrl;
  String? _appleProviderUrl;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          _isLoadingDialogShowing = true;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          ).then((_) => _isLoadingDialogShowing = false);
        }
        if (state is AuthSuccess) {
          if (_isLoadingDialogShowing) {
            Navigator.pop(context);
            _isLoadingDialogShowing = false;
          }
          Navigator.pushReplacementNamed(context, '/home');
        }
        if (state is AuthFailure) {
          if (_isLoadingDialogShowing) {
            Navigator.pop(context);
            _isLoadingDialogShowing = false;
          }
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Sign-in failed',
            text: state.message,
            confirmBtnText: 'Try again',
            confirmBtnColor: AppColors.primary,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Back
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 20),
                      padding: EdgeInsets.zero,
                      color: AppColors.textPrimary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const SizedBox(height: 36),

                  Text(
                    _isSignUpMode ? 'Create your account' : 'Welcome',
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUpMode
                        ? 'Create your osprey.life account.'
                        : 'Sign in to your osprey.life account.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 28),

                  _LabelledField(
                    label: 'Email or username',
                    controller: usernameController,
                    hintText: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    prefix: const Icon(
                      Icons.alternate_email_rounded,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _LabelledField(
                    label: 'Password',
                    controller: passwordController,
                    hintText: 'Enter your password',
                    obscureText: obscurePassword,
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

                  // Agreement
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: agreePolicy,
                          onChanged: (v) =>
                              setState(() => agreePolicy = v ?? false),
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          side: const BorderSide(
                              color: AppColors.border, width: 1.4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Wrap(
                          children: [
                            Text(
                              'I agree to the ',
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                            GestureDetector(
                              onTap: () => launchUrl(
                                  Uri.parse(AppConfig.privacyPolicyUrl)),
                              child: Text(
                                'Privacy Policy',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              ' and ',
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                            GestureDetector(
                              onTap: () => launchUrl(
                                  Uri.parse(AppConfig.userAgreementUrl)),
                              child: Text(
                                'User Agreement',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '.',
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!agreePolicy) {
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.warning,
                            title: 'Agreement required',
                            text:
                                'Please tick the Privacy Policy and User Agreement checkbox to continue.',
                            confirmBtnText: 'Got it',
                            confirmBtnColor: AppColors.primary,
                          );
                          return;
                        }
                        final email = usernameController.text.trim();
                        final password = passwordController.text.trim();
                        if (email.isEmpty || password.isEmpty) {
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.info,
                            title: 'Missing credentials',
                            text: _isSignUpMode
                                ? 'Please enter an email and password to create your account.'
                                : 'Please enter your email and password to sign in.',
                            confirmBtnText: 'OK',
                            confirmBtnColor: AppColors.primary,
                          );
                          return;
                        }
                        if (_isSignUpMode) {
                          // Existing server flow lives in SignUpPage; jump there
                          // pre-filled with the typed email.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpPage(),
                            ),
                          );
                        } else {
                          context.read<AuthBloc>().add(
                                LoginRequested(email, password),
                              );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textInverse,
                        minimumSize: const Size(0, 56),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      child: Text(
                        _isSignUpMode ? 'Create account' : 'Sign in',
                        style: AppTypography.labelLarge.copyWith(
                          fontSize: 15,
                          color: AppColors.textInverse,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Mode toggle — sign-in <-> sign-up inline on the same page.
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          setState(() => _isSignUpMode = !_isSignUpMode),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: _isSignUpMode
                                  ? 'Already have an account? '
                                  : "New to osprey.life? ",
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextSpan(
                              text: _isSignUpMode
                                  ? 'Sign in'
                                  : 'Create one',
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

                  if (!_isSignUpMode) ...[
                    const SizedBox(height: 4),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot password?',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Social login — hidden until server configures OAuth providers
                  // To re-enable: remove the `if` guard below
                  if (_googleProviderUrl != null || _appleProviderUrl != null) ...[
                  // Or continue with divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.divider)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or continue with',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textMuted,
                          ),
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
                        onTap: () => _onSocialTap(_googleProviderUrl, 'Google'),
                        child: const Text('G',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4285F4),
                            )),
                      ),
                      if (_googleProviderUrl != null && _appleProviderUrl != null)
                      const SizedBox(width: 16),
                      if (_appleProviderUrl != null)
                      _SocialIconButton(
                        bgColor: Colors.black,
                        onTap: () => _onSocialTap(_appleProviderUrl, 'Apple'),
                        child: const Icon(Icons.apple,
                            color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                  ], // end if providers available

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onSocialTap(String? providerUrl, String name) {
    if (providerUrl != null) {
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
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

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

class _LabelledField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Widget? suffix;
  final Widget? prefix;
  final TextInputType? keyboardType;

  const _LabelledField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.suffix,
    this.prefix,
    this.keyboardType,
  });

  @override
  State<_LabelledField> createState() => _LabelledFieldState();
}

class _LabelledFieldState extends State<_LabelledField> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            widget.label,
            style: AppTypography.labelMedium.copyWith(
              color: _focused
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.field),
            border: Border.all(
              color: _focused ? AppColors.primary : AppColors.border,
              width: _focused ? 1.8 : 1.2,
            ),
            boxShadow: _focused
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
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            cursorColor: AppColors.primary,
            cursorWidth: 1.6,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTypography.bodyLarge.copyWith(
                color: AppColors.textMuted,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 18),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              prefixIcon: widget.prefix,
              suffixIcon: widget.suffix,
              filled: false,
            ),
          ),
        ),
      ],
    );
  }
}

