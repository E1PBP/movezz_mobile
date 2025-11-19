/// lib/core/routing/app_router.dart
///
/// Router minimal dengan nama-nama route yang dipakai app.
/// Nanti tinggal mapping ke halaman beneran di switch-nya.

import 'package:flutter/material.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
}

/// Fungsi factory untuk onGenerateRoute di MaterialApp.
/// Sekarang masih pakai Scaffold placeholder supaya tetap compile.
/// Ganti isi masing-masing case ke Page yang sebenarnya.
Route<dynamic> appRouteFactory(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.splash:
      return _buildRoute(
        settings,
        const _SimpleScaffold(title: 'Splash'),
      );

    case AppRoutes.login:
      return _buildRoute(
        settings,
        const _SimpleScaffold(title: 'Login'),
      );

    case AppRoutes.home:
      return _buildRoute(
        settings,
        const _SimpleScaffold(title: 'Home'),
      );

    case AppRoutes.profile:
      return _buildRoute(
        settings,
        const _SimpleScaffold(title: 'Profile'),
      );

    default:
      return _buildRoute(
        settings,
        _SimpleScaffold(
          title: 'Unknown route',
          body: Text('No route defined for ${settings.name}'),
        ),
      );
  }
}

PageRoute _buildRoute(RouteSettings settings, Widget child) {
  return MaterialPageRoute(
    settings: settings,
    builder: (_) => child,
  );
}

/// Placeholder Scaffold supaya router tetap jalan
/// walaupun halaman aslinya belum diimplementasi.
class _SimpleScaffold extends StatelessWidget {
  final String title;
  final Widget? body;

  const _SimpleScaffold({
    super.key,
    required this.title,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: body ??
          Center(
            child: Text(title),
          ),
    );
  }
}
