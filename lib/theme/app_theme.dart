import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF5B5BD6);
  static const Color primaryDark = Color(0xFF3E3E9E);
  static const Color accent = Color(0xFF8B5CF6);
  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Colors.white;
  static const Color ink = Color(0xFF1E2233);
  static const Color inkSoft = Color(0xFF6B7185);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );

  static Color gradeColor(double g) {
    if (g >= 4.5) return const Color(0xFF22A06B);
    if (g >= 4.0) return const Color(0xFF6CA821);
    if (g >= 3.5) return const Color(0xFFE0A800);
    return const Color(0xFFE8743B);
  }

  static Color scoreColor(int? score) {
    if (score == null) return inkSoft;
    if (score >= 90) return const Color(0xFF22A06B);
    if (score >= 80) return const Color(0xFF6CA821);
    if (score >= 70) return const Color(0xFFE0A800);
    return const Color(0xFFE8743B);
  }

  static ThemeData build() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(surface: surface);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: ink, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: ink, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: ink),
        bodySmall: TextStyle(color: inkSoft),
      ),
    );
  }
}
