

import 'package:google_fonts/google_fonts.dart';

class AppConfig {
  AppConfig._(); // private constructor

  /// Nama aplikasi (buat title, analytics, dsb).
  static const String appName = 'Movezz';

  /// Versi aplikasi (manual, atau bisa di-sync dengan pubspec).
  static const String appVersion = '1.0.0';

  /// Default page size untuk request paginasi ke backend.
  static const int defaultPageSize = 20;

  /// Default timeout (detik) untuk request HTTP.
  static const int httpTimeoutSeconds = 30;

  /// UI Constants
  static const double containerRadius = 32;
  static const double commonRadius = 12;

  /// Font family
  static String get robotoFont => GoogleFonts.roboto().fontFamily!;
}



