import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  const seed = Color(0xFF355CFF);
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF5F7FF),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      filled: true,
      fillColor: Colors.white,
    ),
  );
}

ThemeData buildDarkTheme() {
  const seed = Color(0xFF7C9BFF);
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF10131F),
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF171B2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      filled: true,
    ),
  );
}
