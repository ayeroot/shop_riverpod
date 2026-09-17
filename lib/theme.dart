import 'package:flutter/material.dart';

/// Thèmes clair et sombre centralisés (Material 3).
class AppTheme {
  static const _seed = Color(0xFF3B6EE8);

  static ThemeData _base(Brightness b) => ThemeData(
        useMaterial3: true,
        brightness: b,
        colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: b),
        appBarTheme: const AppBarTheme(centerTitle: false),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      );

  static ThemeData get light => _base(Brightness.light);
  static ThemeData get dark => _base(Brightness.dark);
}
