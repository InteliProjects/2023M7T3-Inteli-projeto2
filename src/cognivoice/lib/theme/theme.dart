import 'package:flutter/material.dart';

class CogniVoiceTheme {
  static const textTheme = TextTheme(
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Color(0xFFf1f1f1),
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Color(0xFFf1f1f1),
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Color(0xFFf1f1f1),
    ),
    labelSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Color(0xFFf1f1f1),
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Color(0xFFf1f1f1),
    ),
  );

  static var colorScheme = const ColorScheme(
    primary: Color(0xFF0062FF), // primaryVariant: Color(0xFF12307C),
    secondary: Color(0xFF0062FF), // secondaryVariant: Color(0xFF12307C),
    surface: Color(0xFF161616),
    onBackground: Color(0xFF1b1b1b),
    background: Color(0xFF161616),
    error: Color(0xFFEF5350),
    onPrimary: Color(0xFFf1f1f1),
    onSecondary: Color(0xFFf1f1f1),
    onSurface: Color(0xFFf1f1f1),
    onError: Colors.white,
    brightness: Brightness.dark,
  );
}
