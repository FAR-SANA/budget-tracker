import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/notification_service.dart';
import 'package:flutter/services.dart';
import 'screens/welcome_screen.dart'; // ✅ ADDED

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await NotificationService.init();

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

      // ✅ CHANGED: Start with Splash Screen
      home: const WelcomeScreen(),
    );
  }
}