import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'setnewpass.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;

    if (!mounted) return;

    // 🔥 Detect if app opened from email confirmation
    final uri = Uri.base;

    if (uri.scheme == 'com.example.budgee') {
      if (uri.host == 'login') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }

      if (uri.host == 'reset-password') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SetNewPasswordScreen()),
        );
        return;
      }
    }

    // 🔹 Normal app flow
    if (session != null) {
  try {
    final user = Supabase.instance.client.auth.currentUser;

    // 🔥 Try to validate user with backend
    final response = await Supabase.instance.client.auth.getUser();

    if (response.user == null) {
      // ❌ Invalid session → logout
      await Supabase.instance.client.auth.signOut();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    // ✅ Valid session
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  } catch (e) {
    // ❌ Any error → logout
    await Supabase.instance.client.auth.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}  else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6ECFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to",
              style: TextStyle(fontSize: 20, color: Colors.orange),
            ),

            const SizedBox(height: 20),
            Image.asset('assets/images/budgee_logo.png', height: 100),
          ],
        ),
      ),
    );
  }
}
