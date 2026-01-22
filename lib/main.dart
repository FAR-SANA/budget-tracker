import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Supabase
  await Supabase.initialize(
    url: 'https://zpfqupnigkvfrjukuquq.supabase.co',
    anonKey: 'sb_publishable_iTpvGf7x_nu48jJYcc88oA__SWIRoB-',
  );

  runApp(const BudgeeApp());
}

class BudgeeApp extends StatelessWidget {
  const BudgeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budgee',

      // ✅ Start with Login Screen
      home: const LoginScreen(),
    );
  }
}
