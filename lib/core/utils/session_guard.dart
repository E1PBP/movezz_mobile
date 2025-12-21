import 'package:flutter/material.dart';
import 'package:movezz_mobile/core/routing/app_router.dart';
import '../config/navigator_key.dart';

class SessionGuard {
  static const List<String> excludedRoutes = [
    AppRoutes.login,
    AppRoutes.splash,
  ];

  static void handleSessionExpired() {
    if (currentRouteName != null && excludedRoutes.contains(currentRouteName)) {
      return;
    }

    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.lock_clock, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Session expired. Please log in again.",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  static dynamic validate(dynamic response) {
    if (response is String && response.contains('<html')) {
      handleSessionExpired();
      throw Exception("Session expired");
    }

    if (response is Map) {
      if (response['status'] == 401 || response['status'] == 403) {
        handleSessionExpired();
        throw Exception("Session expired");
      }
    }
    return response;
  }
}
