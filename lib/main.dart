import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const BudgeeApp());
}

class BudgeeApp extends StatelessWidget {
  const BudgeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budgee',
      home: const LoginScreen(), // ✅ ONLY ONE HOME
    );
  }
}
