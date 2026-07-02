import 'package:flutter/material.dart';

class AppTypography {
  const AppTypography._();

  static const String? fontFamily = null;

  static const TextTheme textTheme = TextTheme(
    displaySmall: TextStyle(
      fontSize: 36,
      height: 1.08,
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      height: 1.18,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    titleLarge: TextStyle(
      fontSize: 21,
      height: 1.22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: 17,
      height: 1.3,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    titleSmall: TextStyle(
      fontSize: 15,
      height: 1.35,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    bodyLarge: TextStyle(fontSize: 16, height: 1.45, letterSpacing: 0),
    bodyMedium: TextStyle(fontSize: 14, height: 1.45, letterSpacing: 0),
    bodySmall: TextStyle(fontSize: 12, height: 1.35, letterSpacing: 0),
    labelLarge: TextStyle(
      fontSize: 14,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
  );
}
