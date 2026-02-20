import 'package:flutter/material.dart';
import 'forgot_password_screen.dart'; // ✅ ADD THIS
import 'package:supabase_flutter/supabase_flutter.dart';


class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool hasMinLength = false;
  bool hasUpper = false;
  bool hasLower = false;
  bool hasNumber = false;
  bool hasSpecial = false;

bool get isValid =>
    currentCtrl.text.isNotEmpty &&
    hasMinLength &&
    hasUpper &&
    hasLower &&
    hasNumber &&
    hasSpecial &&
    newCtrl.text == confirmCtrl.text &&
    newCtrl.text.isNotEmpty;


  @override
  void initState() {
    super.initState();
    newCtrl.addListener(_validatePassword);
      // 🔥 ADD THIS
  confirmCtrl.addListener(() {
    setState(() {});
  });
  }

  void _validatePassword() {
    final text = newCtrl.text;

    setState(() {
      hasMinLength = text.length >= 8;
      hasUpper = RegExp(r'[A-Z]').hasMatch(text);
      hasLower = RegExp(r'[a-z]').hasMatch(text);
      hasNumber = RegExp(r'[0-9]').hasMatch(text);
      hasSpecial = RegExp(r'[!@#\$&*~]').hasMatch(text);
    });
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE
            const Center(
              child: Text(
                "Change Password",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF142752),
                ),
              ),
            ),

            const SizedBox(height: 30),

            _input(
              controller: currentCtrl,
              hint: "Current Password *",
              obscure: true,
            ),

            const SizedBox(height: 6),

            // ✅ CLICKABLE FORGOT PASSWORD
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  );
                },

                child: const Text(
                  "Forgot password?",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 16),

            _input(controller: newCtrl, hint: "New Password", obscure: true),

            const SizedBox(height: 16),

            _input(
              controller: confirmCtrl,
              hint: "Confirm New Password",
              obscure: true,
            ),

            const SizedBox(height: 25),

            const Divider(),

            const SizedBox(height: 10),

            _rule(hasMinLength, "8 or more characters"),
            _rule(hasUpper, "At least 1 uppercase letter"),
            _rule(hasLower, "At least 1 lower case letter"),
            _rule(hasNumber, "At least 1 number"),
            _rule(hasSpecial, "At least 1 special character"),

            const SizedBox(height: 20),

            const Divider(),

            const SizedBox(height: 25),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isValid ? _save : null,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF142752),
                  disabledBackgroundColor: const Color(
                    0xFF142752,
                  ).withOpacity(0.4),

                  padding: const EdgeInsets.symmetric(vertical: 16),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: const Text(
                  "Save",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,

      decoration: InputDecoration(
        hintText: hint,

        filled: true,
        fillColor: const Color(0xFFE8EEFF),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _rule(bool active, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(
        children: [
          Icon(
            active ? Icons.check_circle : Icons.radio_button_unchecked,
            color: active ? const Color(0xFF142752) : Colors.grey,
            size: 20,
          ),

          const SizedBox(width: 10),

          Text(
            text,
            style: TextStyle(
              color: active ? const Color(0xFF142752) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
Future<void> _save() async {
  final supabase = Supabase.instance.client;

  if (!mounted) return;

  try {
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    // 🔐 Step 1: Reauthenticate
    await supabase.auth.signInWithPassword(
      email: user.email!,
      password: currentCtrl.text.trim(),
    );

    // 🔐 Step 2: Update password
    await supabase.auth.updateUser(
      UserAttributes(password: newCtrl.text.trim()),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password updated successfully")),
    );

    Navigator.pop(context);

  } on AuthException catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message)),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Something went wrong")),
    );
  }
}

}
