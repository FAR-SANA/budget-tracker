import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_profile_screen.dart';
import 'accounts/all_accounts_screen.dart';
import 'change_password_screen.dart';
import '../services/sms_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  bool _openedSettings = false;
  String name = "";
  String userId = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadUserData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Detect when user returns from settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _openedSettings) {
      _openedSettings = false;

      // We only re-check silently (no snackbar)
      _checkPermissionStatus();
    }
  }

  Future<void> loadUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final uid = user?.id;

      if (uid == null) {
        setState(() => isLoading = false);
        return;
      }

      final data = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', uid)
          .maybeSingle();

      setState(() {
        name = data?['name'] ?? ""; // ✅ SAFE NULL CHECK
        userId = uid;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading user: $e");
      setState(() => isLoading = false);
    }
  }

  // Open system settings
  Future<void> _handleNotification() async {
    _openedSettings = true;
    await openAppSettings();
  }

  // Silent permission check (no UI feedback)
  Future<void> _checkPermissionStatus() async {
    await Permission.notification.status;
    // Intentionally no snackbar or UI change
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0, // ✅ ADD THIS
        surfaceTintColor: Colors.white, // ✅ ADD THIS
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 60, // ✅ increase this if needed
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFFB3E5FC),
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoading
                            ? "Loading..."
                            : (name.isEmpty ? "No Name" : name),

                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(255, 179, 0, 1),
                        ),
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ================= ACCOUNT =================
              const Text(
                "Account Settings",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1A2B5D),
                ),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.indigo),
                      title: const Text("Edit Profile"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );

                        loadUserData(); // refresh profile after returning
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock, color: Colors.indigo),
                      title: const Text("Change Password"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.sms, color: Colors.indigo),
                      title: const Text("Enable SMS Tracking"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _showSmsDialog,
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.manage_accounts,
                        color: Colors.indigo,
                      ),
                      title: const Text("Manage Accounts"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        final changed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AllAccountsScreen(),
                          ),
                        );

                        if (changed == true) {
                          Navigator.pop(
                            context,
                            true,
                          ); // 🔥 send back to HomeScreen
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ================= PREFERENCES =================
              const Text(
                "Preferences",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1A2B5D),
                ),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // 🔔 Manage Notification
                    ListTile(
                      leading: const Icon(
                        Icons.notifications,
                        color: Colors.indigo,
                      ),
                      title: const Text("Manage Notification"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _handleNotification,
                    ),
                    const ListTile(
                      leading: Icon(Icons.dark_mode, color: Colors.indigo),
                      title: Text("Dark Mode"),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                    const ListTile(
                      leading: Icon(Icons.shield, color: Colors.indigo),
                      title: Text("Terms Of Use"),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                    ListTile(
  leading: const Icon(Icons.logout, color: Colors.red),
  title: const Text(
    "Logout",
    style: TextStyle(color: Colors.red),
  ),
  trailing: const Icon(
    Icons.arrow_forward_ios,
    size: 16,
    color: Colors.red,
  ),
  onTap: _handleLogout, // 👈 ADD THIS
),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _showSmsDialog() {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Enable SMS Tracking"),
      content: const Text(
        "Budgee can automatically detect debit and credit "
        "transactions from your bank SMS messages.\n\n"
        "We only read transaction-related messages.\n"
        "We do NOT store or upload your personal SMS.\n\n"
        "Do you want to enable SMS tracking?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await _enableSmsTracking();
          },
          child: const Text("Enable"),
        ),
      ],
    ),
  );
}

Future<void> _enableSmsTracking() async {
  final status = await Permission.sms.request();

  if (status.isGranted) {
    SmsService.startListening();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("SMS tracking enabled")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("SMS permission denied")),
    );
  }
}

Future<void> _handleLogout() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Logout"),
      content: const Text("Are you sure you want to logout?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Logout"),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  try {
    await Supabase.instance.client.auth.signOut();

    if (!mounted) return;

    // 🔥 IMPORTANT: Clear all screens and go to login
    Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => const LoginScreen()),
  (route) => false,
);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Logout failed: $e")),
    );
  }
}

}
