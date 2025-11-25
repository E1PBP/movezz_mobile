import 'package:flutter/material.dart';

extension StringExt on String {
  /// "halo dunia" -> "Halo dunia"
  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// "  teks  " -> "teks" atau null kalau kosong
  String? get nullIfEmptyAfterTrim {
    final trimmed = trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

extension BuildContextExt on BuildContext {
  /// Cepat buat SnackBar
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Cepat pop route kalau masih bisa.
  void safePop<T extends Object?>([T? result]) {
    if (Navigator.of(this).canPop()) {
      Navigator.of(this).pop(result);
    }
  }
}

extension DateTimeExt on DateTime {
  /// Format simple "dd/MM/yyyy"
  String toShortDateString() {
    final dayStr = day.toString().padLeft(2, '0');
    final monthStr = month.toString().padLeft(2, '0');
    final yearStr = year.toString();
    return '$dayStr/$monthStr/$yearStr';
  }
}
