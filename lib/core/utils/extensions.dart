import 'package:flutter/material.dart';
import '../theme/app_theme.dart';




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
    /// Menampilkan SnackBar dengan styling modern
  /// [isError] = true akan membuat background merah, false (default) warna primary
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).clearSnackBars(); // Hapus snackbar antrian sebelumnya
    
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16), 
        duration: const Duration(seconds: 3),
      ),
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
