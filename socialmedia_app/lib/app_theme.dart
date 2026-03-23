import 'package:flutter/material.dart';

class CozyTheme {
  static const Color background = Color(0xFFFDFBF7);
  static const Color primaryTeal = Color(0xFF00695C);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: primaryTeal,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,

      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
    );
  }
}
