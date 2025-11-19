/// lib/core/config/env.dart
///
/// Kelas Env menyimpan konfigurasi dasar aplikasi,
/// terutama base URL backend Django.
class Env {
  /// Base URL backend Django.
  ///
  /// Default: http://10.0.2.2:8000 (akses localhost dari Android emulator).
  /// Bisa dioverride pakai:
  /// flutter run --dart-define=BACKEND_BASE_URL=https://api.domainmu.com
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// Helper untuk gabung baseUrl + path endpoint.
  ///
  /// Env.api('/auth/login/') -> http://10.0.2.2:8000/auth/login/
  static String api(String path) {
    if (path.startsWith('/')) {
      return '$backendBaseUrl$path';
    }
    return '$backendBaseUrl/$path';
  }
}
