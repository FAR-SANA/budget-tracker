import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);

    try {
      final response =
          await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (response.user != null) {
        // ✅ Directly go to Home (no onboarding here)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6ECFF), Color(0xFFC7D2FF)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              width: 320,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color:
                                    Colors.white.withOpacity(0.75),
                                borderRadius:
                                    BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white
                                      .withOpacity(0.35),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 16,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/budgee_logo.png',
                                    height: 80,
                                  ),

                                  const SizedBox(height: 20),

                                  const Text(
                                    "Welcome Back!",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: Color(0xFF1A2B5D),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                          "Don't have an account? "),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const SignupScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Sign Up",
                                          style: TextStyle(
                                            color:
                                                Color(0xFF1A2B5D),
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  TextField(
                                    controller:
                                        _emailController,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                          Icons.email_outlined),
                                      hintText: "Email ID",
                                      filled: true,
                                      fillColor: Colors.white
                                          .withOpacity(0.75),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                                14),
                                        borderSide:
                                            BorderSide.none,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  TextField(
                                    controller:
                                        _passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                          Icons.lock_outline),
                                      hintText: "Password",
                                      filled: true,
                                      fillColor: Colors.white
                                          .withOpacity(0.75),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                                14),
                                        borderSide:
                                            BorderSide.none,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed:
                                          _loading
                                              ? null
                                              : _login,
                                      style:
                                          ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(
                                                0xFF1A2B5D),
                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                                      14),
                                        ),
                                      ),
                                      child: _loading
                                          ? const CircularProgressIndicator(
                                              color:
                                                  Colors.white,
                                            )
                                          : const Text(
                                              "Login",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors
                                                    .white,
                                                fontWeight:
                                                    FontWeight
                                                        .w600,
                                              ),
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ForgotPasswordScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Forgot password?",
                                      style: TextStyle(
                                          color:
                                              Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}