import 'dart:ui';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isPasswordHidden = true;

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
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.35),
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
                                  children: [
                                    // ---------- LOGO ----------
                                    Image.asset(
                                      'assets/images/budgee_logo.png',
                                      height: 60,
                                    ),

                                    const SizedBox(height: 20),

                                    // ---------- TITLE ----------
                                    const Text(
                                      "Create Your Account",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A2B5D),
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    // ---------- SIGN IN LINK ----------
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Already have an account? ",
                                          style: TextStyle(
                                            color: Colors.black87,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const LoginScreen(),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            "Sign In",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1A2B5D),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 24),

                                    // ---------- NAME ----------
                                    TextField(
                                      decoration: InputDecoration(
                                        hintText: "Full Name",
                                        prefixIcon: const Icon(
                                          Icons.person_outline,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(
                                          0.75,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // ---------- EMAIL ----------
                                    TextField(
                                      decoration: InputDecoration(
                                        hintText: "Email ID",
                                        prefixIcon: const Icon(
                                          Icons.email_outlined,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(
                                          0.75,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // ---------- PASSWORD ----------
                                    TextField(
                                      obscureText: isPasswordHidden,
                                      decoration: InputDecoration(
                                        hintText: "Password",
                                        prefixIcon: const Icon(
                                          Icons.lock_outline,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            isPasswordHidden
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              isPasswordHidden =
                                                  !isPasswordHidden;
                                            });
                                          },
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(
                                          0.75,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 28),

                                    // ---------- SIGN UP BUTTON ----------
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF1A2B5D,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          elevation: 4,
                                        ),
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const WelcomeScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Sign Up",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
