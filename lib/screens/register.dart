import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:goalytics_mobile/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Hover states
  bool _hoverRegister = false;
  bool _hoverLoginText = false;
  bool _hoverUsername = false;
  bool _hoverPassword = false;
  bool _hoverConfirm = false;
  bool _hoverEyePassword = false;
  bool _hoverEyeConfirm = false;

  // Password visibility
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFF111836),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 340,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= TITLE =================
                const Center(
                  child: Column(
                    children: [
                      Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Join the Goalytics community",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ================= USERNAME =================
                const Text("Username",
                    style: TextStyle(fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 6),
                _hoverableInput(
                  hover: _hoverUsername,
                  onHover: (v) => setState(() => _hoverUsername = v),
                  controller: _usernameController,
                  hint: "Create username",
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 18),

                // ================= PASSWORD =================
                const Text("Password",
                    style: TextStyle(fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 6),
                _hoverableInput(
                  hover: _hoverPassword,
                  onHover: (v) => setState(() => _hoverPassword = v),
                  controller: _passwordController,
                  hint: "Create password",
                  icon: Icons.lock_outline,
                  obscure: !_showPassword,
                  suffixIcon: _eyeIcon(
                    hovered: _hoverEyePassword,
                    onHover: (v) =>
                        setState(() => _hoverEyePassword = v),
                    onTap: () =>
                        setState(() => _showPassword = !_showPassword),
                    visible: _showPassword,
                  ),
                ),

                const SizedBox(height: 18),

                // ================= CONFIRM PASSWORD =================
                const Text("Confirm Password",
                    style: TextStyle(fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 6),
                _hoverableInput(
                  hover: _hoverConfirm,
                  onHover: (v) => setState(() => _hoverConfirm = v),
                  controller: _confirmPasswordController,
                  hint: "Confirm password",
                  icon: Icons.lock_outline,
                  obscure: !_showConfirmPassword,
                  suffixIcon: _eyeIcon(
                    hovered: _hoverEyeConfirm,
                    onHover: (v) =>
                        setState(() => _hoverEyeConfirm = v),
                    onTap: () => setState(() =>
                        _showConfirmPassword = !_showConfirmPassword),
                    visible: _showConfirmPassword,
                  ),
                ),

                const SizedBox(height: 26),

                // ================= REGISTER BUTTON =================
                MouseRegion(
                  onEnter: (_) => setState(() => _hoverRegister = true),
                  onExit: (_) => setState(() => _hoverRegister = false),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final response = await request.postJson(
                          "https://jefferson-tirza-goalytics.pbp.cs.ui.ac.id/auth/register/",
                          jsonEncode({
                            "username": _usernameController.text,
                            "password1": _passwordController.text,
                            "password2":
                                _confirmPasswordController.text,
                          }),
                        );

                        // 🔑 SESUAI BACKEND ANDA
                        if (response['status'] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Registration successful!")),
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                response['message'] ??
                                    "Registration failed.",
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hoverRegister
                            ? const Color(0xFF2A3372)
                            : const Color(0xFF1A2048),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Register",
                        style:
                            TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ================= SIGN IN TEXT =================
                Center(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) =>
                        setState(() => _hoverLoginText = true),
                    onExit: (_) =>
                        setState(() => _hoverLoginText = false),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginPage()),
                        );
                      },
                      child: Text(
                        "Already have an account?  Sign In",
                        style: TextStyle(
                          color: _hoverLoginText
                              ? const Color(0xFF000B7A)
                              : const Color(0xFF1A2048),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= HELPERS =================

  Widget _eyeIcon({
    required bool hovered,
    required Function(bool) onHover,
    required VoidCallback onTap,
    required bool visible,
  }) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Icon(
          visible
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: hovered ? const Color(0xFF1A2048) : Colors.grey,
        ),
      ),
    );
  }

  Widget _hoverableInput({
    required bool hover,
    required Function(bool) onHover,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xfff5f6fa),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                hover ? const Color(0xFF1A2048) : const Color(0xffe4e6ed),
            width: hover ? 1.4 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(icon,
                color: hover ? const Color(0xFF1A2048) : Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscure,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
            if (suffixIcon != null) suffixIcon,
          ],
        ),
      ),
    );
  }
}
