import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

class SmartSplashScreen extends StatefulWidget {
  const SmartSplashScreen({super.key});

  @override
  State<SmartSplashScreen> createState() => _SmartSplashScreenState();
}

class _SmartSplashScreenState extends State<SmartSplashScreen>
    with TickerProviderStateMixin {
  bool _showUI = false;
  late AnimationController _logoController;
  late Animation<double> _logoScale;

  late AnimationController _loginController;
  late AnimationController _signupController;
  late AnimationController _guestController;

  late Animation<Offset> _loginSlide;
  late Animation<Offset> _signupSlide;
  late Animation<Offset> _guestFadeSlide;

  @override
  void initState() {
    super.initState();

    _logoController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _loginController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _signupController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _guestController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _loginSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _loginController, curve: Curves.easeOutCubic));

    _signupSlide = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _signupController, curve: Curves.easeOutCubic));

    _guestFadeSlide = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _guestController, curve: Curves.easeOutCubic));

    _logoController.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() => _showUI = true);
      _loginController.forward();
      await Future.delayed(const Duration(milliseconds: 200));
      _signupController.forward();
      await Future.delayed(const Duration(milliseconds: 200));
      _guestController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _loginController.dispose();
    _signupController.dispose();
    _guestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF40C4FF), Color(0xFF00BFA5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 80),
              Center(
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Column(
                    children: [
                      Image.asset('assets/logo.png', width: 120, height: 120),
                      const SizedBox(height: 20),
                      const Text(
                        'Smart Home',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedOpacity(
                        opacity: _showUI ? 1 : 0,
                        duration: const Duration(milliseconds: 800),
                        child: const Text(
                          'Control your home, anywhere',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Column(
                  children: [
                    SlideTransition(
                      position: _loginSlide,
                      child: ElevatedButton(
                        onPressed: () {
                          // ✅ điều hướng tới LoginPage, chia sẻ AuthBloc
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
                          backgroundColor: Colors.white,
                          minimumSize: const Size(300, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            color: Color(0xFF00BFA5),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SlideTransition(
                      position: _signupSlide,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 2),
                          minimumSize: const Size(300, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SlideTransition(
                      position: _guestFadeSlide,
                      child: GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Try as a Guest',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white54,
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
      ),
    );
  }
}
