import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() =>
      _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState
    extends State<SetNewPasswordScreen> {
  final TextEditingController passwordController =
      TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
bool isLoading = false;

  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
late final StreamSubscription<AuthState> _authSubscription;
bool hasRecoverySession = false;

@override
void initState() {
  super.initState();

  _authSubscription =
      Supabase.instance.client.auth.onAuthStateChange.listen(
    (data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        setState(() {
          hasRecoverySession = true;
        });
      }
    },
  );

  // Also check if session already exists
  final session =
      Supabase.instance.client.auth.currentSession;
  if (session != null) {
    hasRecoverySession = true;
  }
}

@override
void dispose() {
  _authSubscription.cancel();
  passwordController.dispose();
  confirmPasswordController.dispose();
  super.dispose();
}
  void validatePassword(String value) {
    setState(() {
      hasMinLength = value.length >= 8;
      hasUppercase = value.contains(RegExp(r'[A-Z]'));
      hasLowercase = value.contains(RegExp(r'[a-z]'));
      hasNumber = value.contains(RegExp(r'[0-9]'));
      hasSpecialChar =
          value.contains(RegExp(r'[!@#\$&*~]'));
    });
  }

  bool get isPasswordValid =>
      hasMinLength &&
      hasUppercase &&
      hasLowercase &&
      hasNumber &&
      hasSpecialChar;

  Widget buildRule(bool isValid, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isValid
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: isValid ? Colors.green : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: !isPasswordVisible,
      onChanged: validatePassword,
      decoration: InputDecoration(
        hintText: "New Password",
        filled: true,
        fillColor: Colors.blue[50],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible
                ? Icons.visibility
                : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextField(
      controller: confirmPasswordController,
      obscureText: !isConfirmPasswordVisible,
      decoration: InputDecoration(
        hintText: "Confirm New Password",
        filled: true,
        fillColor: Colors.blue[50],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isConfirmPasswordVisible
                ? Icons.visibility
                : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              isConfirmPasswordVisible =
                  !isConfirmPasswordVisible;
            });
          },
        ),
      ),
    );
  }
Future<void> savePassword() async {
  final password = passwordController.text.trim();
  final confirm = confirmPasswordController.text.trim();

  if (!isPasswordValid) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password does not meet requirements")),
    );
    return;
  }

  if (password != confirm) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Passwords do not match")),
    );
    return;
  }

  setState(() => isLoading = true);

  try {
    final supabase = Supabase.instance.client;

    await supabase.auth.updateUser(
      UserAttributes(password: password),
    );

    await supabase.auth.signOut();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password updated successfully")),
    );

    Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const LoginScreen()),
  (route) => false,
);
  } on AuthException catch (e) {

    // 🔥 Handle session missing cleanly
    if (e.message.toLowerCase().contains("session")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Reset link expired. Please request a new password reset."),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/forgot-password',
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }

  if (mounted) setState(() => isLoading = false);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child:
                    const Icon(Icons.arrow_back, size: 26),
              ),

              const SizedBox(height: 25),

              const Text(
                "Set New Password",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Create a strong password to secure your account.",
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14),
              ),

              const SizedBox(height: 30),

              _buildPasswordField(),

              const SizedBox(height: 20),

              _buildConfirmPasswordField(),

              const SizedBox(height: 25),

              buildRule(
                  hasMinLength, "8 or more characters"),
              buildRule(hasUppercase,
                  "At least 1 uppercase letter"),
              buildRule(hasLowercase,
                  "At least 1 lowercase letter"),
              buildRule(
                  hasNumber, "At least 1 number"),
              buildRule(hasSpecialChar,
                  "At least 1 special character"),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                 onPressed: isLoading ? null : savePassword,
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    backgroundColor:
                        const Color(0xFF142752),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
    ? const CircularProgressIndicator(color: Colors.white)
    : const Text(
        "Save Password",
        style: TextStyle(fontSize: 16),
      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}