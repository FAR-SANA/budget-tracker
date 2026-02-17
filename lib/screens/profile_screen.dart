import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {

  bool _openedSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
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
                  children: const [
                    Text(
                      "Naomi",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFB300),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "User ID: juliette_123",
                      style: TextStyle(color: Colors.grey),
                    ),
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
                    trailing:
                        const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock, color: Colors.indigo),
                    title: const Text("Change Password"),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  const ListTile(
                    leading: Icon(Icons.sms, color: Colors.indigo),
                    title: Text("Enable SMS Tracking"),
                    trailing:
                        Icon(Icons.arrow_forward_ios, size: 16),
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
                    trailing:
                        const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _handleNotification,
                  ),
                  const ListTile(
                    leading:
                        Icon(Icons.dark_mode, color: Colors.indigo),
                    title: Text("Dark Mode"),
                    trailing:
                        Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  const ListTile(
                    leading:
                        Icon(Icons.shield, color: Colors.indigo),
                    title: Text("Terms Of Use"),
                    trailing:
                        Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  const ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      "Logout",
                      style: TextStyle(color: Colors.red),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
