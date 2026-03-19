import 'package:flutter/material.dart';

class AppColors {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ================= BACKGROUND =================
  static Color background(BuildContext context) =>
      isDark(context) ? const Color(0xFF0D1B2A) : Colors.white;

  // ================= TEXT =================
  static Color text(BuildContext context) =>
      isDark(context) ? Colors.white : const Color(0xFF142752);

  static Color subText(BuildContext context) =>
      isDark(context) ? Colors.white70 : Colors.grey;

  static Color darkBlueText(BuildContext context) => const Color(0xFF142752);

  // ================= HEADER FIX =================
  static Color headerBg(BuildContext context) => isDark(context)
      ? const Color(0xFF0B2239) // slightly lighter than background ✅
      : Colors.white;

  // ================= CARDS =================
  static Color incomeCard(BuildContext context) => isDark(context)
      ? const Color(0xFF1E3A5F) // soft blue for dark mode ✅
      : const Color(0xFFE3F2FD);

  static Color expenseCard(BuildContext context) => isDark(context)
      ? const Color(0xFFB1AE74) // tinted yellow for dark mode ✅
      : const Color(0xFFFFF8E1);

  // ================= HIGHLIGHT =================
  static Color highlight(BuildContext context) => isDark(context)
      ? const Color(0xFFFFC107) // brighter yellow for dark ✅
      : const Color(0xFFFFB300);

  // ================= PRIMARY =================
  static Color primary(BuildContext context) =>
      isDark(context) ? const Color(0xFF1E3A5F) : const Color(0xFF142752);

  // ================= TABS =================
  static Color activeTab(BuildContext context) =>
      isDark(context) ? Colors.white : const Color(0xFF142752);

  static Color inactiveTab(BuildContext context) =>
      isDark(context) ? Colors.white38 : Colors.blue.shade200;
}
