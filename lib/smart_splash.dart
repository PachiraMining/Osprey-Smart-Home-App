import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_radius.dart';
import 'core/theme/app_typography.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'l10n/gen/app_l10n.dart';
import 'core/theme/app_surfaces.dart';

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

  late AnimationController _bgController;
  late AnimationController _glowController;
  late AnimationController _particleController;

  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
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

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    final rng = Random();
    _particles = List.generate(
      18,
      (_) => _Particle(
        x: rng.nextDouble(),
        offset: rng.nextDouble(),
        radius: 2.5 + rng.nextDouble() * 4,
        phase: rng.nextDouble() * pi * 2,
        speed: 0.6 + rng.nextDouble() * 0.4,
      ),
    );

    context.read<AuthBloc>().add(CheckAuthStatusEvent());

    // The native splash (splash 1) is the ONLY splash: it stays up while auth
    // resolves, then we go straight to the destination. There is no animated
    // Flutter splash for logged-in users — HomePage lifts the native splash the
    // instant it has painted, so it reads as native splash → Home.
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
    _bgController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Chỉ auto-điều hướng khi splash đang trên cùng (cold-start
        // auto-login). Khi LoginPage/SignUpPage ở trên, trang đó tự điều
        // hướng — tránh push '/home' hai lần (HomePage init đôi).
        if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
        if (state is AuthSuccess && !_navigated) {
          _navigated = true;
          // Logged in → straight to Home. Native splash stays up through the
          // push and HomePage removes it after its first frame → native → Home,
          // no intermediate Flutter splash.
          Navigator.pushReplacementNamed(context, '/home');
        } else if (state is AuthInitial && !_navigated) {
          // Logged out → the welcome/login screen is the destination. Lift the
          // native splash to reveal it (its content fades in — see below).
          FlutterNativeSplash.remove();
        }
      },
      child: Scaffold(
        backgroundColor: context.surfaces.pageBg,
        body: Stack(
          children: [
            // Layer 1: Living-room photo background + soft white scrim so the
            // logo, text and Get Started button stay readable.
            Positioned.fill(
              child: Image.asset(
                'assets/images/home_bg.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
                errorBuilder: (_, __, ___) =>  DecoratedBox(
                  decoration: BoxDecoration(color: context.surfaces.pageBg),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withAlpha(90),
                      Colors.white.withAlpha(40),
                      Colors.white.withAlpha(110),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Layer 2: Floating particles (optimized — 18 only, blurred circles)
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _ParticlePainter(
                        _particleController.value,
                        _particles,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Layer 3: Waves at bottom
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _bgController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _WavePainter(_bgController.value),
                    );
                  },
                ),
              ),
            ),

            // Accent orb bottom-right
            Positioned(
              right: -100,
              bottom: -140,
              child: Container(
                width: 340,
                height: 340,
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
                  SizedBox(height: screenHeight * 0.2),

                  // Logo with breathing glow — no card frame
                  Center(
                    child: FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Breathing glow
                            AnimatedBuilder(
                              animation: _glowController,
                              builder: (context, _) {
                                final v = _glowController.value;
                                return Container(
                                  width: 220,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(60),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accent
                                            .withValues(alpha: 0.05 + v * 0.07),
                                        blurRadius: 35 + v * 25,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            Image.asset(
                              'assets/osprey_life_logo.png',
                              width: 300,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Get started
                  if (_showUI)
                    SlideTransition(
                      position: _ctaSlide,
                      child: FadeTransition(
                        opacity: _ctaFade,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<AuthBloc>(),
                                    child: const LoginPage(),
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.textInverse,
                                minimumSize: const Size(0, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.lg),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                AppL10n.of(context).getStarted,
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.textInverse,
                                  fontSize: 15,
                                ),
                              ),
                            ),
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

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

class _Particle {
  final double x;
  final double offset;
  final double radius;
  final double phase;
  final double speed;

  const _Particle({
    required this.x,
    required this.offset,
    required this.radius,
    required this.phase,
    required this.speed,
  });
}

// ---------------------------------------------------------------------------
// Painters
// ---------------------------------------------------------------------------

class _ParticlePainter extends CustomPainter {
  final double t;
  final List<_Particle> particles;

  _ParticlePainter(this.t, this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final progress = (t * p.speed + p.offset) % 1.0;
      final x = p.x * size.width + sin(progress * pi * 2 + p.phase) * 18;
      final y = size.height * (1.0 - progress);
      final opacity = (1.0 - (progress - 0.5).abs() * 2).clamp(0.0, 1.0);

      canvas.drawCircle(
        Offset(x, y),
        p.radius,
        Paint()
          ..color = AppColors.accent.withValues(alpha: opacity * 0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.t != t;
}

class _WavePainter extends CustomPainter {
  final double t;

  _WavePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 3; i++) {
      final path = Path()..moveTo(0, size.height);
      final waveH = 14.0 + i * 5;
      final speed = t * pi * 2 + i * 0.9;
      final yBase = size.height * (0.83 + i * 0.05);

      for (double x = 0; x <= size.width; x += 3) {
        path.lineTo(x, yBase + sin(x / size.width * pi * 2 + speed) * waveH);
      }
      path.lineTo(size.width, size.height);
      path.close();

      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.02 + i * 0.01)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => old.t != t;
}
