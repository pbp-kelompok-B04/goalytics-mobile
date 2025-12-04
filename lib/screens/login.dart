import 'package:flutter/material.dart';
import 'package:goalytics_mobile/config.dart';
import 'package:goalytics_mobile/menu.dart';
import 'package:goalytics_mobile/screens/register.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  // Hover states
  bool _hoverUsername = false;
  bool _hoverPassword = false;
  bool _hoverEye = false;
  bool _hoverForgot = false;
  bool _hoverSignup = false;
  bool _hoverButton = false;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFF111836),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),

              const CircleAvatar(
                radius: 36,
                backgroundColor: Colors.white,
                child: Icon(Icons.sports_soccer, size: 36, color: Colors.black),
              ),

              const SizedBox(height: 14),
              const Text(
                "Goalytics",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Your football companion",
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),

              const SizedBox(height: 30),

              Container(
                width: 340,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Column(
                        children: [
                          Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Sign in to continue",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "Username",
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),

                    // USERNAME INPUT
                    MouseRegion(
                      onEnter: (_) => setState(() => _hoverUsername = true),
                      onExit: (_) => setState(() => _hoverUsername = false),
                      child: _inputField(
                        controller: _usernameController,
                        hint: "Enter your username",
                        icon: Icons.person_outline,
                        hovered: _hoverUsername,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "Password",
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),

                    // PASSWORD INPUT
                    MouseRegion(
                      onEnter: (_) => setState(() => _hoverPassword = true),
                      onExit: (_) => setState(() => _hoverPassword = false),
                      child: _inputField(
                        controller: _passwordController,
                        hint: "Enter your password",
                        icon: Icons.lock_outline,
                        obscure: _obscurePassword,
                        hovered: _hoverPassword,
                        suffix: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onEnter: (_) => setState(() => _hoverEye = true),
                          onExit: (_) => setState(() => _hoverEye = false),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: _hoverEye ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // FORGOT PASSWORD
                    Align(
                      alignment: Alignment.centerRight,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onEnter: (_) => setState(() => _hoverForgot = true),
                        onExit: (_) => setState(() => _hoverForgot = false),
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: _hoverForgot
                                ? const Color(0xFF000B7A)
                                : const Color(0xFF1A2048),
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // SIGN IN BUTTON
                    MouseRegion(
                      onEnter: (_) => setState(() => _hoverButton = true),
                      onExit: (_) => setState(() => _hoverButton = false),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            final response = await request.login(
                              "$kApiBaseUrl/auth/login/",
                              {
                                'username': _usernameController.text,
                                'password': _passwordController.text,
                              },
                            );

                            if (request.loggedIn) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const MyHomePage(title: "Dashboard"),
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Login Failed"),
                                  content: Text(response['message']),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("OK"),
                                    )
                                  ],
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _hoverButton
                                ? const Color(0xFF2A3372)
                                : const Color(0xFF1A2048),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // SIGN UP TEXT
                    Center(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onEnter: (_) => setState(() => _hoverSignup = true),
                        onExit: (_) => setState(() => _hoverSignup = false),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterPage()),
                            );
                          },
                          child: Text(
                            "Don't have an account?  Sign Up",
                            style: TextStyle(
                              color: _hoverSignup
                                  ? const Color(0xFF000B7A)
                                  : const Color(0xFF1A2048),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================
  // CUSTOM INPUT FIELD WITH HOVER EFFECT
  // ========================================
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    bool hovered = false,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xfff5f6fa),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hovered ? const Color(0xFF1A2048) : const Color(0xffe4e6ed),
          width: hovered ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(icon, color: hovered ? Colors.black : Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          if (suffix != null) ...[
            const SizedBox(width: 6),
            suffix,
            const SizedBox(width: 12),
          ]
        ],
      ),
    );
  }
}
