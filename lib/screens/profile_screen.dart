import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_profile_screen.dart';
import 'accounts/all_accounts_screen.dart';
import 'change_password_screen.dart';
import '../services/sms_service.dart';
import 'login_screen.dart';
import '../theme/app_colors.dart';
import 'terms_of_use_screen.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

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

      if (!mounted) return;
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

      if (!mounted) return;

      setState(() {
        name = data?['name'] ?? "";
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

    if (!mounted) return;
  }

  // Silent permission check (no UI feedback)
  Future<void> _checkPermissionStatus() async {
    await Permission.notification.status;
    // Intentionally no snackbar or UI change
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),

      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        scrolledUnderElevation: 0, // ✅ ADD THIS
        surfaceTintColor: AppColors.background(context), // ✅ ADD THIS
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text(context)),
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
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: AppColors.incomeCard(context),
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
                          color: AppColors.highlight(context),
                        ),
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ================= ACCOUNT =================
              Text(
                "Account Settings",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.text(context),
                ),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.incomeCard(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.person,
                        color: AppColors.text(context),
                      ),
                      title: Text(
                        "Edit Profile",
                        style: TextStyle(color: AppColors.text(context)),
                      ),
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
                      leading: Icon(Icons.lock, color: AppColors.text(context)),
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
                      leading: Icon(Icons.sms, color: AppColors.text(context)),
                      title: const Text("Enable SMS Tracking"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _showSmsDialog,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.manage_accounts,
                        color: AppColors.text(context),
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
              Text(
                "Preferences",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.text(context),
                ),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.incomeCard(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // 🔔 Manage Notification
                    ListTile(
                      leading: Icon(
                        Icons.notifications,
                        color: AppColors.text(context),
                      ),
                      title: const Text("Manage Notification"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _handleNotification,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.dark_mode,
                        color: AppColors.text(context),
                      ),
                      title: const Text("Dark Mode"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _showThemeDialog,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.shield,
                        color: AppColors.text(context),
                      ),
                      title: Text(
                        "Terms Of Use",
                        style: TextStyle(
                          color: AppColors.text(context),
                        ), // ✅ optional but better
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16, // ✅ better for theme
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TermsOfUseScreen(),
                          ),
                        );
                      },
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
        backgroundColor: AppColors.background(context),
        titleTextStyle: TextStyle(color: AppColors.text(context), fontSize: 18),
        contentTextStyle: TextStyle(color: AppColors.subText(context)),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("SMS tracking enabled")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("SMS permission denied")));
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background(context),
        titleTextStyle: TextStyle(color: AppColors.text(context), fontSize: 18),
        contentTextStyle: TextStyle(color: AppColors.subText(context)),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Logout failed: $e")));
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return AlertDialog(
              backgroundColor: AppColors.background(context),
              title: Text(
                "Choose Theme",
                style: TextStyle(color: AppColors.text(context)),
              ),

              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Dark Mode",
                    style: TextStyle(color: AppColors.text(context)),
                  ),

                  Switch(
                    value: themeProvider.isDark,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
