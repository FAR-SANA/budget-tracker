import 'dart:async';
import 'package:flutter/material.dart';
import 'check_email_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  bool isLoading = false;
  bool isCooldown = false;
  int cooldownSeconds = 0;
  Timer? cooldownTimer;

  Future<void> sendResetEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await Supabase.instance.client.auth
          .resetPasswordForEmail(
        email,
        redirectTo:
            'com.example.budgee://reset-password',
      );

      if (!mounted) return;

      startCooldown();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CheckEmailScreen(),
        ),
      );
    } on AuthException catch (e) {
      if (e.statusCode == 429) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Too many attempts. Please try again later."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    if (mounted) setState(() => isLoading = false);
  }

  void startCooldown() {
    setState(() {
      isCooldown = true;
      cooldownSeconds = 60;
    });

    cooldownTimer =
        Timer.periodic(const Duration(seconds: 1),
            (timer) {
      if (cooldownSeconds == 0) {
        timer.cancel();
        setState(() => isCooldown = false);
      } else {
        setState(() => cooldownSeconds--);
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            const Icon(Icons.lock_outline,
                size: 80,
                color: Color(0xFF1A2B5D)),

            const SizedBox(height: 20),

            const Text(
              "Forgot Password",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              "Enter the email associated with your account.\nWe'll send you the reset link.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: emailController,
              keyboardType:
                  TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.email),
                hintText: "Email ID",
                filled: true,
                fillColor:
                    const Color(0xFFF0F4FF),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    (isLoading || isCooldown)
                        ? null
                        : sendResetEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF1A2B5D),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : Text(
                        isCooldown
                            ? "Wait $cooldownSeconds s"
                            : "Reset Password",
                        style:
                            const TextStyle(
                                fontSize: 16,
                                color:
                                    Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}