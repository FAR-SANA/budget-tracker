import 'package:flutter/material.dart';

// ================= LIGHT THEME =================
class AppTheme {
  static const Color lightBg = Colors.white;
  static const Color lightText = Color(0xFF142752); // navy
  static const Color incomeCard = Color(0xFFE3F2FD); // light blue
  static const Color expenseCard = Color(0xFFFFF8E1); // light yellow
  static const Color highlight = Color(0xFFFFB300); // dark yellow

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,

    appBarTheme: const AppBarTheme(
      backgroundColor: lightBg,
      foregroundColor: lightText,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: lightText),
      bodyMedium: TextStyle(color: lightText),
    ),

    iconTheme: const IconThemeData(color: lightText),

    cardColor: incomeCard,
  );

  // ================= DARK THEME =================
  static const Color darkBg = Color(0xFF0D1B2A); // dark blue
  static const Color darkText = Colors.white;
  static const Color darkBlueText = Color(0xFF142752);
  static const Color darkIncome = Color(0xFFE3F2FD);
  static const Color darkExpense = Color(0xFFFFF8E1);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,

    appBarTheme: const AppBarTheme(
      backgroundColor: darkBg,
      foregroundColor: darkText,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkText),
      bodyMedium: TextStyle(color: darkText),
    ),

    iconTheme: const IconThemeData(color: darkText),

    cardColor: darkIncome,
  );
}