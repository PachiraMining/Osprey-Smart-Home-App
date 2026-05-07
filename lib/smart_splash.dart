import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_radius.dart';
import 'core/theme/app_typography.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/sign_up_page.dart';

class SmartSplashScreen extends StatefulWidget {
  const SmartSplashScreen({super.key});

  @override
  State<SmartSplashScreen> createState() => _SmartSplashScreenState();
}

class _SmartSplashScreenState extends State<SmartSplashScreen>
    with TickerProviderStateMixin {
  bool _showUI = false;
  bool _navigated = false;
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;

  late AnimationController _buttonsController;
  late Animation<double> _ctaFade;
  late Animation<Offset> _ctaSlide;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _buttonsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _ctaFade = CurvedAnimation(
      parent: _buttonsController,
      curve: Curves.easeOut,
    );
    _ctaSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(_ctaFade);

    context.read<AuthBloc>().add(CheckAuthStatusEvent());

    _logoController.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!_navigated && mounted) {
        setState(() => _showUI = true);
        _buttonsController.forward();
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess && !_navigated) {
          _navigated = true;
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Layered radial gradient — distinct from typical smart-home splash.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.4, -0.7),
                    radius: 1.4,
                    colors: [
                      AppColors.primarySubtle,
                      AppColors.background,
                    ],
                    stops: const [0.0, 0.85],
                  ),
                ),
              ),
            ),

            // Subtle gold orb bottom-right for depth.
            Positioned(
              right: -120,
              bottom: -160,
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentSubtle,
                      AppColors.background.withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.16),

                  // Brand mark
                  Center(
                    child: FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 28,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/eagle_logo.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  FadeTransition(
                    opacity: _logoFade,
                    child: Column(
                      children: [
                        Text(
                          'Osprey',
                          style: AppTypography.displayMedium.copyWith(
                            color: AppColors.primary,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Smart living, refined.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  if (_showUI)
                    SlideTransition(
                      position: _ctaSlide,
                      child: FadeTransition(
                        opacity: _ctaFade,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider.value(
                                          value: context.read<AuthBloc>(),
                                          child: const LoginPage(),
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.textInverse,
                                    minimumSize: const Size(0, 56),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.lg),
                                    ),
                                  ),
                                  child: Text(
                                    'Sign in',
                                    style: AppTypography.labelLarge.copyWith(
                                      color: AppColors.textInverse,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SignUpPage(),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    minimumSize: const Size(0, 56),
                                    side: const BorderSide(
                                      color: AppColors.border,
                                      width: 1.4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.lg),
                                    ),
                                  ),
                                  child: Text(
                                    'Create account',
                                    style: AppTypography.labelLarge.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  'Continue as guest',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
