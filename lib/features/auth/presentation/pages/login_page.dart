import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

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
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        }
        if (state is AuthSuccess) {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/home');
        }
        if (state is AuthFailure) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        // Back button
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 22),
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          color: Colors.black87,
                          onPressed: () => Navigator.pop(context),
                        ),

                        const SizedBox(height: 24),

                        // Title
                        const Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Country dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCountry,
                              isExpanded: true,
                              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Vietnam', child: Text('Vietnam')),
                                DropdownMenuItem(value: 'Singapore', child: Text('Singapore')),
                                DropdownMenuItem(value: 'United States', child: Text('United States')),
                              ],
                              onChanged: (v) => setState(() => selectedCountry = v!),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Username field
                        _buildInputField(
                          controller: usernameController,
                          hintText: 'Please enter your account',
                        ),

                        const SizedBox(height: 16),

                        // Password field
                        _buildInputField(
                          controller: passwordController,
                          hintText: 'Password',
                          obscureText: obscurePassword,
                        ),

                        const SizedBox(height: 28),

                        // Agreement
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: agreePolicy,
                                onChanged: (v) => setState(() => agreePolicy = v!),
                                activeColor: const Color(0xFF2196F3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Wrap(
                                children: [
                                  const Text(
                                    'I agree to the ',
                                    style: TextStyle(fontSize: 14, color: Colors.black87),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: const Text(
                                      'Privacy Policy',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF2196F3),
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    ' and ',
                                    style: TextStyle(fontSize: 14, color: Colors.black87),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: const Text(
                                      'User Agreement',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF2196F3),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
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
                              backgroundColor: const Color(0xFFD5E3EC),
                              disabledBackgroundColor: const Color(0xFFD5E3EC),
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white70,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Forgot password
                        Center(
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Forgot Password',
                              style: TextStyle(
                                color: Color(0xFF2196F3),
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Social login buttons fixed at bottom
                Padding(
                  padding: const EdgeInsets.only(bottom: 36, top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        icon: Icons.facebook,
                        color: const Color(0xFF1877F2),
                        bgColor: const Color(0xFF1877F2),
                        iconColor: Colors.white,
                      ),
                      const SizedBox(width: 28),
                      _buildSocialButtonImage('assets/icons/google_logo.png'),
                      const SizedBox(width: 28),
                      _buildSocialButton(
                        icon: Icons.apple,
                        color: Colors.black,
                        bgColor: Colors.black,
                        iconColor: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 15,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2196F3), width: 1.2),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 28),
      ),
    );
  }

  Widget _buildSocialButtonImage(String assetPath) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Center(
          child: Image.asset(assetPath, width: 26, height: 26),
        ),
      ),
    );
  }
}
