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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool agreePolicy = false;
  bool obscurePassword = true;
  String selectedCountry = 'Vietnam';
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
                  const SizedBox(height: 8),

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
                    'Welcome back',
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to manage your Osprey home.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Region selector — stylised pill
                  _RegionSelector(
                    value: selectedCountry,
                    onChanged: (v) => setState(() => selectedCountry = v),
                  ),

                  const SizedBox(height: 18),

                  _LabelledField(
                    label: 'Email or username',
                    controller: usernameController,
                    hintText: 'you@osprey.io',
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
                      onPressed: agreePolicy
                          ? () {
                              context.read<AuthBloc>().add(
                                    LoginRequested(
                                      usernameController.text.trim(),
                                      passwordController.text.trim(),
                                    ),
                                  );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.surfaceMuted,
                        foregroundColor: AppColors.textInverse,
                        disabledForegroundColor: AppColors.textMuted,
                        minimumSize: const Size(0, 56),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      child: Text(
                        'Sign in',
                        style: AppTypography.labelLarge.copyWith(
                          fontSize: 15,
                          color: agreePolicy
                              ? AppColors.textInverse
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
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

                  const SizedBox(height: 18),
                  const _OrDivider(),
                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialIconButton(
                        child: Image.asset(
                          'assets/icons/google_logo.png',
                          width: 24,
                          height: 24,
                        ),
                        onTap: agreePolicy
                            ? () => _onSocialTap(
                                context, _googleProviderUrl, 'Google')
                            : null,
                      ),
                      const SizedBox(width: 18),
                      _SocialIconButton(
                        bgColor: AppColors.textPrimary,
                        child: const Icon(Icons.apple,
                            color: Colors.white, size: 26),
                        onTap: agreePolicy
                            ? () => _onSocialTap(
                                context, _appleProviderUrl, 'Apple')
                            : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onSocialTap(
      BuildContext context, String? providerUrl, String name) {
    if (providerUrl != null) {
      context.read<AuthBloc>().add(SocialLoginRequested(providerUrl));
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Unavailable',
        text: '$name sign-in is not configured on the server.',
        confirmBtnColor: AppColors.primary,
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

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

class _RegionSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _RegionSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Icon(Icons.public, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                isDense: true,
                icon: Icon(Icons.expand_more, color: AppColors.primary),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
                dropdownColor: AppColors.surface,
                items: const [
                  DropdownMenuItem(value: 'Vietnam', child: Text('Vietnam')),
                  DropdownMenuItem(
                      value: 'Singapore', child: Text('Singapore')),
                  DropdownMenuItem(
                      value: 'United States', child: Text('United States')),
                ],
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: AppTypography.caption,
          ),
        ),
        Expanded(child: Divider(color: AppColors.divider)),
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
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
