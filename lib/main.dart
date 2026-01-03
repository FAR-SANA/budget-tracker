import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const BudgeeApp());
}

class BudgeeApp extends StatelessWidget {
  const BudgeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
