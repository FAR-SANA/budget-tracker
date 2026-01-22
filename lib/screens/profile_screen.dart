import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
            _settingsCard([
              _settingsItem(Icons.person_outline, "Edit Profile"),
              _settingsItem(Icons.lock_outline, "Change Password"),
              _settingsItem(Icons.sms_outlined, "Enable SMS Tracking"),
              _settingsItem(Icons.person_add_alt, "Add Account"),
            ]),

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
            _settingsCard([
              _settingsItem(Icons.notifications_none, "Manage Notification"),
              _settingsItem(Icons.dark_mode_outlined, "Dark Mode"),
              _settingsItem(Icons.shield_outlined, "Terms Of Use"),
              _settingsItem(
                Icons.logout,
                "Logout",
                isLogout: true,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  /// SETTINGS CARD CONTAINER
  Widget _settingsCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children : children),
    );
  }

  /// INDIVIDUAL ROW
  Widget _settingsItem(
    IconData icon,
    String title, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : Colors.indigo,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.black,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isLogout ? Colors.red : Colors.grey,
      ),
      onTap: () {},
    );
  }
}
