import 'package:flutter/material.dart';
import '../config/app_config.dart';
import 'package:google_fonts/google_fonts.dart';
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFFA3E635);
  static const Color primaryLight = Color(0xFFF9FAFF);

  // Background colors
  static const Color layoutBackground = Color(0xFFF4F7F6);
  static const Color sectionBackground = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardBackgroundDark = Color(0xFF1F1F1F);
  static const Color primaryBlack = Color(0xFF131d25);

  // Border and divider colors
  static const Color border = Color(0xFFD9DFEB);
  static const Color divider = Color(0xFFE1E5EF);

  // Body text colors
  static const Color bodyWhite = Color(0xFF6F7F92);
  static const Color bodyDark = Color(0xFFF5F5F5);

  // Icon colors
  static const Color iconPrimaryDark = Color(0xFF212121);
  static const Color iconSecondaryDark = Color(0xFFA8ABAD);

  // Shadow colors
  static const Color shadowDark = Color(0x1A3E3942);
}

class AppTheme {
  AppTheme._();

  /// Tema utama aplikasi - Light Theme
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.primary,
      brightness: Brightness.light,
    );

    return base.copyWith(
      textTheme: GoogleFonts.latoTextTheme(base.textTheme),
      scaffoldBackgroundColor: AppColors.layoutBackground,
      cardColor: AppColors.sectionBackground,
      primaryColor: AppColors.primary,
      appBarTheme: base.appBarTheme.copyWith(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        border: UnderlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        alignLabelWithHint: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.commonRadius),
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),
    );
  }
  
}