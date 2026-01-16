import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Future<void> _requestNotificationPermissionAndGoHome() async {
  await Permission.notification.request();

  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const HomeScreen()),
  );
}


  bool isReminderEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 30),

              /// Welcome Text
              const Text(
                "Welcome to",
                style: TextStyle(fontSize: 18, color: Colors.orange),
              ),

              const SizedBox(height: 10),

              /// App Name
              const Text(
                "BUDGEE",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2B5D),
                ),
              ),

              const SizedBox(height: 6),

              /// Tagline
              const Text(
                "Track where your money goes. Effortlessly.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 30),

              /// Highlight Text
              const Text(
                "Get daily reminders so you never\nmiss an expense",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 30),

              /// Reminder Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    /// Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.notifications_active,
                        size: 50,
                        color: Color(0xFF1A2B5D),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Toggle Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Enable daily reminders",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Switch(
  value: false, // 👈 always OFF
  activeThumbColor: Colors.indigo,
  onChanged: (value) async {
    await _requestNotificationPermissionAndGoHome();
  },
),

                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// Info Text
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline, size: 18, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Turn on notifications to get daily reminders for adding expenses. You can always turn it off later.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              /// Skip Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                  child: const Text(
                    "SKIP FOR NOW  >",
                    style: TextStyle(
                      color: Color(0xFF1A2B5D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
