/// lib/core/utils/validators.dart
///
/// Fungsi validator sederhana untuk dipakai di TextFormField.

class Validators {
  Validators._();

  /// Wajib diisi
  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  /// Minimal [min] karakter
  static String? minLength(
    String? value, {
    required int min,
    String fieldName = 'Field',
  }) {
    if (value == null || value.length < min) {
      return '$fieldName minimal $min karakter';
    }
    return null;
  }

  /// Email sederhana (tidak super strict)
  static String? email(String? value, {String fieldName = 'Email'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    const pattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(value.trim())) {
      return '$fieldName tidak valid';
    }
    return null;
  }

  /// Kombinasi beberapa validator:
  /// pertama yang gagal akan direturn.
  static String? compose(
    List<String? Function(String?)> validators,
    String? value,
  ) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) return result;
    }
    return null;
  }
}
