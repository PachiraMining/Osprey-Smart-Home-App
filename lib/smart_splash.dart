import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/sign_up_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

class SmartSplashScreen extends StatefulWidget {
  const SmartSplashScreen({super.key});

  @override
  State<SmartSplashScreen> createState() => _SmartSplashScreenState();
}

class _SmartSplashScreenState extends State<SmartSplashScreen>
    with TickerProviderStateMixin {
  static const _bgColor = Color(0xFFD5E3EC);
  static const _navyDark = Color(0xFF1A3A6E);

  bool _showUI = false;
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;

  late AnimationController _buttonsController;
  late Animation<Offset> _loginSlide;
  late Animation<Offset> _signupSlide;
  late Animation<Offset> _guestSlide;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _buttonsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _loginSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonsController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _signupSlide = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonsController,
      curve: const Interval(0.15, 0.75, curve: Curves.easeOutCubic),
    ));

    _guestSlide = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonsController,
      curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
    ));

    _logoController.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() => _showUI = true);
      _buttonsController.forward();
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

    return Scaffold(
      body: Stack(
        children: [
          // Full screen light blue background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: _bgColor,
          ),

          // Furniture background image at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: screenHeight * 0.45,
              child: Stack(
                children: [
                  // Furniture image
                  Positioned.fill(
                    child: Image.asset(
                      'assets/splash_bg.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                  // Top fade gradient so image blends into background
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [_bgColor, Color(0x00D5E3EC)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Logo area - positioned around 28% from top
                SizedBox(height: screenHeight * 0.22),
                Center(
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Image.asset(
                        'assets/eagle_logo.png',
                        width: 160,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Buttons area - overlaid on bottom portion
                if (_showUI)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50.0, left: 40, right: 40),
                    child: Column(
                      children: [
                        // Log In button
                        SlideTransition(
                          position: _loginSlide,
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
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
                                backgroundColor: _navyDark,
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: _navyDark.withAlpha(140),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Sign Up button
                        SlideTransition(
                          position: _signupSlide,
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignUpPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: _navyDark,
                                elevation: 4,
                                shadowColor: Colors.black.withAlpha(40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Guest link
                        SlideTransition(
                          position: _guestSlide,
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Try as a Guest',
                              style: TextStyle(
                                color: _navyDark.withAlpha(160),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                decorationColor: _navyDark.withAlpha(100),
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
        ],
      ),
    );
  }
}
