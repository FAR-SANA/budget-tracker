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
            // Profile Header
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
                        color: Colors.orange,
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

            // Account Settings
            const Text(
              "Account Settings",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 10),

            _settingsCard([
              _settingsItem(Icons.person, "Edit Profile"),
              _settingsItem(Icons.lock, "Change Password"),
              _settingsItem(Icons.sms, "Enable SMS Tracking"),
            ]),

            const SizedBox(height: 25),

            // Settings
            const Text(
              "Settings",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 10),

            _settingsCard([
              _settingsItem(Icons.notifications, "Enable Notification"),
              _settingsItem(Icons.shield, "Terms Of Use"),
              _settingsItem(Icons.logout, "Logout", isLogout: true),
            ]),
          ],
        ),
      ),
    );
  }

  // Settings Card Container
  Widget _settingsCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  // Individual Row
  Widget _settingsItem(IconData icon, String title,
      {bool isLogout = false}) {
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
