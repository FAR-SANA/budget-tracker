import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'home_screen.dart'; // ✅ CHANGED: Added HomeScreen import

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isPasswordHidden = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final supabase = Supabase.instance.client;

  Stream<AuthState>? _authStateStream; // ✅ CHANGED: Added auth stream

  @override
  void initState() {
    super.initState();

    // ✅ CHANGED: Listen for email verification (signed in event)
    _authStateStream = supabase.auth.onAuthStateChange;

    _authStateStream!.listen((data) {
      final event = data.event;

      if (event == AuthChangeEvent.signedIn && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    });
  }

  // ✅ SIGN UP FUNCTION (UNCHANGED)
  Future<void> signUpUser() async {
    try {
      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = response.user;
      final session = response.session;

      if (user == null) {
        throw 'Signup failed. Try again.';
      }

      if (session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Account created! Please verify your email before logging in.",
            ),
          ),
        );

        return;
      }

    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
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
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                  sigmaX: 12, sigmaY: 12),
                              child: Container(
                                padding:
                                    const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(0.75),
                                  borderRadius:
                                      BorderRadius.circular(
                                          24),
                                  border: Border.all(
                                    color: Colors.white
                                        .withOpacity(0.35),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color:
                                          Colors.black12,
                                      blurRadius: 16,
                                      offset:
                                          Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/budgee_logo.png',
                                      height: 60,
                                    ),

                                    const SizedBox(
                                        height: 20),

                                    const Text(
                                      "Create Your Account",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight:
                                            FontWeight.bold,
                                        color:
                                            Color(0xFF1A2B5D),
                                      ),
                                    ),

                                    const SizedBox(
                                        height: 6),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                      children: [
                                        const Text(
                                          "Already have an account? ",
                                          style:
                                              TextStyle(
                                            color: Colors
                                                .black87,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator
                                                .pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const LoginScreen(),
                                              ),
                                            );
                                          },
                                          child:
                                              const Text(
                                            "Sign In",
                                            style:
                                                TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              color: Color(
                                                  0xFF1A2B5D),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                        height: 24),

                                    TextField(
                                      controller:
                                          nameController,
                                      decoration:
                                          InputDecoration(
                                        hintText:
                                            "Full Name",
                                        prefixIcon:
                                            const Icon(
                                          Icons
                                              .person_outline,
                                        ),
                                        filled: true,
                                        fillColor: Colors
                                            .white
                                            .withOpacity(
                                                0.75),
                                        border:
                                            OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                                      14),
                                          borderSide:
                                              BorderSide
                                                  .none,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                        height: 16),

                                    TextField(
                                      controller:
                                          emailController,
                                      decoration:
                                          InputDecoration(
                                        hintText:
                                            "Email ID",
                                        prefixIcon:
                                            const Icon(
                                          Icons
                                              .email_outlined,
                                        ),
                                        filled: true,
                                        fillColor: Colors
                                            .white
                                            .withOpacity(
                                                0.75),
                                        border:
                                            OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                                      14),
                                          borderSide:
                                              BorderSide
                                                  .none,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                        height: 16),

                                    TextField(
                                      controller:
                                          passwordController,
                                      obscureText:
                                          isPasswordHidden,
                                      decoration:
                                          InputDecoration(
                                        hintText:
                                            "Password",
                                        prefixIcon:
                                            const Icon(
                                          Icons
                                              .lock_outline,
                                        ),
                                        suffixIcon:
                                            IconButton(
                                          icon: Icon(
                                            isPasswordHidden
                                                ? Icons
                                                    .visibility_off
                                                : Icons
                                                    .visibility,
                                          ),
                                          onPressed:
                                              () {
                                            setState(() {
                                              isPasswordHidden =
                                                  !isPasswordHidden;
                                            });
                                          },
                                        ),
                                        filled: true,
                                        fillColor: Colors
                                            .white
                                            .withOpacity(
                                                0.75),
                                        border:
                                            OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                                      14),
                                          borderSide:
                                              BorderSide
                                                  .none,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                        height: 28),

                                    SizedBox(
                                      width: double
                                          .infinity,
                                      height: 52,
                                      child:
                                          ElevatedButton(
                                        style:
                                            ElevatedButton
                                                .styleFrom(
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
                                          elevation: 4,
                                        ),
                                        onPressed:
                                            signUpUser,
                                        child:
                                            const Text(
                                          "Sign Up",
                                          style:
                                              TextStyle(
                                            fontSize:
                                                16,
                                            color: Colors
                                                .white,
                                            fontWeight:
                                                FontWeight
                                                    .w600,
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
