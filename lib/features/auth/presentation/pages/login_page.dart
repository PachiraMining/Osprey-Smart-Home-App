import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/features/auth/presentation/bloc/auth_bloc.dart';
import '/features/auth/presentation/bloc/auth_event.dart';
import '/features/auth/presentation/bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool agreePolicy = false;
  bool obscurePassword = true;
  String selectedCountry = 'Vietnam';

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
          Navigator.pop(context); // đóng loading
          Navigator.pushReplacementNamed(context, '/home');
        }

        if (state is AuthFailure) {
          Navigator.pop(context); // đóng loading
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: _buildLoginContent(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nút back nằm sát mép trái
        Padding(
          padding: const EdgeInsets.only(left: 0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Đăng nhập',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),

              // Country dropdown
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCountry,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'Vietnam',
                        child: Text('Vietnam'),
                      ),
                      DropdownMenuItem(
                        value: 'Singapore',
                        child: Text('Singapore'),
                      ),
                      DropdownMenuItem(
                        value: 'United States',
                        child: Text('United States'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedCountry = value!);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Username
              _buildInputField(
                controller: usernameController,
                labelText: 'Vui lòng nhập tài khoản',
                hasClearButton: true,
              ),

              const SizedBox(height: 16),

              // Password
              _buildInputField(
                controller: passwordController,
                labelText: 'Mật khẩu',
                obscureText: obscurePassword,
                hasClearButton: true,
                hasVisibilityToggle: true,
              ),

              const SizedBox(height: 36),

              // Agreement
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: agreePolicy,
                    onChanged: (v) => setState(() => agreePolicy = v!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      children: [
                        const Text(
                          'Tôi đồng ý ',
                          style: TextStyle(fontSize: 13),
                        ),
                        _buildLinkText('Chính sách về quyền riêng tư'),
                        const Text(', ', style: TextStyle(fontSize: 13)),
                        _buildLinkText('Thỏa thuận người dùng'),
                        const Text(' và ', style: TextStyle(fontSize: 13)),
                        _buildLinkText("Children's Privacy Statement"),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 48,
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
                    backgroundColor: const Color(0xFFFFE0D5),
                    disabledBackgroundColor: const Color(0xFFFFE0D5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Đăng nhập',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Quên mật khẩu',
                    style: TextStyle(color: Colors.blue, fontSize: 15),
                  ),
                ),
              ),

              const SizedBox(height: 80),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton('assets/icons/google_logo.png'),
                  const SizedBox(width: 40),
                  _buildSocialButton('assets/icons/apple_logo.png'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Input field widget
  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    bool hasClearButton = false,
    bool hasVisibilityToggle = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        labelText: labelText,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
        floatingLabelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 1.2),
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasClearButton && controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, size: 20, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    controller.clear();
                  });
                },
              ),
            if (hasVisibilityToggle)
              IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() => obscurePassword = !obscurePassword);
                },
              ),
          ],
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildLinkText(String text) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        style: const TextStyle(color: Colors.blue, fontSize: 13),
      ),
    );
  }

  Widget _buildSocialButton(String assetPath) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          assetPath,
          height: 46,
          width: 46,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
