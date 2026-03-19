import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),

      appBar: AppBar(
        title: Text(
          "Terms of Use",
          style: TextStyle(color: AppColors.text(context)),
        ),
        backgroundColor: AppColors.background(context),
        iconTheme: IconThemeData(color: AppColors.text(context)),
        elevation: 0,
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(context, "Welcome to Budgee"),

              _paragraph(
                context,
                "By using Budgee, you agree to these terms. Please read them carefully before using the application.",
              ),

              const SizedBox(height: 20),

              _sectionTitle(context, "Use of the App"),

              _paragraph(
                context,
                "Budgee is designed to help you track your expenses, manage budgets, and monitor financial activity. You agree to use the app only for lawful purposes and personal financial management.",
              ),

              const SizedBox(height: 20),

              _sectionTitle(context, "User Data"),

              _paragraph(
                context,
                "You are responsible for the accuracy of the data you enter. Budgee stores your financial data securely using Supabase, but you are responsible for maintaining the confidentiality of your account.",
              ),

              const SizedBox(height: 20),

              _sectionTitle(context, "Privacy"),

              _paragraph(
                context,
                "Your data is not sold or shared with third parties. The app may process your data to provide features like reminders, analytics, and insights.",
              ),

              const SizedBox(height: 20),

              _sectionTitle(context, "Account Responsibility"),

              _paragraph(
                context,
                "You are responsible for maintaining the security of your account credentials. Any activity under your account is your responsibility.",
              ),

              const SizedBox(height: 20),

              _sectionTitle(context, "Limitations"),

              _paragraph(
                context,
                "Budgee is not a financial advisory service. The app provides tracking tools only and does not guarantee financial outcomes or advice.",
              ),

              const SizedBox(height: 20),

              _sectionTitle(context, "Changes to Terms"),

              _paragraph(
                context,
                "These terms may be updated from time to time. Continued use of the app after changes means you accept the updated terms.",
              ),

              const SizedBox(height: 30),

              Center(
                child: Text(
                  "Last updated: 2026",
                  style: TextStyle(
                    color: AppColors.subText(context),
                    fontSize: 12,
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

  // ---------------- UI HELPERS ----------------

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.text(context),
      ),
    );
  }

  Widget _paragraph(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: AppColors.subText(context),
        ),
      ),
    );
  }
}