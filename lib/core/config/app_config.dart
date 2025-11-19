/// lib/core/config/app_config.dart
///
/// Konfigurasi global aplikasi yang sifatnya statis.
/// Kalau butuh yang dinamis/remote, bisa bikin service terpisah.
class AppConfig {
  AppConfig._(); // private constructor

  /// Nama aplikasi (buat title, analytics, dsb).
  static const String appName = 'Movezz Flutter';

  /// Versi aplikasi (manual, atau bisa di-sync dengan pubspec).
  static const String appVersion = '1.0.0';

  /// Default page size untuk request paginasi ke backend.
  static const int defaultPageSize = 20;

  /// Default timeout (detik) untuk request HTTP.
  static const int httpTimeoutSeconds = 30;
}
