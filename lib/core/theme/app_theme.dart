/// lib/core/theme/app_theme.dart
///
/// Definisi tema global aplikasi.

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  /// Tema utama (light).
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.indigo,
      brightness: Brightness.light,
    );

    return base.copyWith(
      scaffoldBackgroundColor: Colors.grey[50],
      appBarTheme: base.appBarTheme.copyWith(
        centerTitle: true,
        elevation: 0,
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  /// (Opsional) tema dark, kalau nanti kamu butuh dark mode.
  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.indigo,
      brightness: Brightness.dark,
    );

    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}
