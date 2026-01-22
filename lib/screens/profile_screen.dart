import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ ADD
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ✅ FUNCTION TO OPEN APP SETTINGS
  Future<void> _openNotificationSettings() async {
    final Uri uri = Uri.parse('app-settings:');

    if (!await launchUrl(uri)) {
      throw 'Could not open app settings';
    }
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
            /// PROFILE HEADER
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

            /// ACCOUNT SETTINGS TITLE
            const Text(
              "Account Settings",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1A2B5D),
              ),
            ),

            const SizedBox(height: 10),

            /// ACCOUNT SETTINGS CARD
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  /// EDIT PROFILE
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.indigo),
                    title: const Text("Edit Profile"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),

                  /// CHANGE PASSWORD
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

                  /// MANAGE NOTIFICATIONS ✅ UPDATED
                  ListTile(
                    leading: const Icon(Icons.sms, color: Colors.indigo),
                    title: const Text("Enable SMS Tracking"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                    onTap: _openNotificationSettings,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// PREFERENCES TITLE
            const Text(
              "Preferences",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1A2B5D),
              ),
            ),

            const SizedBox(height: 10),

            /// PREFERENCES CARD
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.notifications, color: Colors.indigo),
                    title: Text("Manage Notification"),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),

                  ListTile(
                    leading: Icon(Icons.dark_mode, color: Colors.indigo),
                    title: Text("Dark Mode"),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),

                  ListTile(
                    leading: Icon(Icons.shield, color: Colors.indigo),
                    title: Text("Terms Of Use"),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),

                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text("Logout", style: TextStyle(color: Colors.red)),
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
