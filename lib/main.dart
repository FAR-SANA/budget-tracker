import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/notification_service.dart';
import 'package:flutter/services.dart';
import 'screens/welcome_screen.dart'; // ✅ ADDED
import 'screens/setnewpass.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';
import 'package:telephony/telephony.dart';
import 'screens/login_screen.dart';

@pragma('vm:entry-point')
Future<void> backgroundSmsHandler(SmsMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase for background isolate
  await Supabase.initialize(
    url: 'https://zpfqupnigkvfrjukuquq.supabase.co',
    anonKey: 'sb_publishable_iTpvGf7x_nu48jJYcc88oA__SWIRoB-',
  );

  final body = message.body ?? "";

  print("========== SMS DETECTED ==========");
  print("Sender: ${message.address}");
  print("Message: $body");
  print("Date: ${message.date}");
  print("==================================");

  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  print("User in background: $user");

  if (user == null) return;

  // ---------------------------
  // 1️⃣ Extract amount
  // ---------------------------
  final regex = RegExp(r'(?:Rs\.?|INR|₹)\s?(\d+)');
  final match = regex.firstMatch(body);

  if (match == null) return;

  final amount = double.parse(match.group(1)!);

  // ---------------------------
  // 2️⃣ Detect record type
  // ---------------------------
  String recordType;

  if (body.toLowerCase().contains("credited")) {
    recordType = "income";
  } else if (body.toLowerCase().contains("debited")) {
    recordType = "expense";
  } else {
    return;
  }

  // ---------------------------
  // 3️⃣ Get default account
  // ---------------------------
  final account = await supabase
      .from('accounts')
      .select()
      .eq('user_id', user.id)
      .eq('is_default', true)
      .single();

  // ---------------------------
  // 4️⃣ Generate title
  // ---------------------------
  final countResult = await supabase
      .from('records')
      .select('record_id')
      .eq('user_id', user.id);

  final count = (countResult as List).length + 1;

  final title = "Bank SMS Record $count";

  // ---------------------------
  // 5️⃣ Insert record
  // ---------------------------
  await supabase.from('records').insert({
    'title': title,
    'amount': amount,
    'record_type': recordType,
    'category_name': 'miscellaneous',
    'account_id': account['account_id'],
    'record_date': DateTime.now().toIso8601String().split('T').first,
    'user_id': user.id,
  });

  print("Record created: $title ₹$amount");
}

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await NotificationService.init();

  await Supabase.initialize(
    url: 'https://zpfqupnigkvfrjukuquq.supabase.co',
    anonKey: 'sb_publishable_iTpvGf7x_nu48jJYcc88oA__SWIRoB-',
  );

  final telephony = Telephony.instance;

  // REQUEST PERMISSION
  await telephony.requestPhoneAndSmsPermissions;

  Telephony.instance.listenIncomingSms(
    onNewMessage: backgroundSmsHandler,
    onBackgroundMessage: backgroundSmsHandler,
    listenInBackground: true,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const BudgeeApp(),
    ),
  );
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
  final event = data.event;

  // 🔐 PASSWORD RESET FLOW
  if (event == AuthChangeEvent.passwordRecovery) {
    navKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SetNewPasswordScreen()),
      (route) => false,
    );
  }

  // ✅ EMAIL CONFIRMATION FLOW (ONLY when app opened from email)
  if (event == AuthChangeEvent.signedIn &&
      data.session?.user.emailConfirmedAt != null &&
      data.session?.user.lastSignInAt == data.session?.user.emailConfirmedAt) {

    navKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
});
}

class BudgeeApp extends StatelessWidget {
  const BudgeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          navigatorKey: navKey,
          debugShowCheckedModeBanner: false,
          title: 'Budgee',

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,

          home: const WelcomeScreen(),
        );
      },
    );
  }
}
