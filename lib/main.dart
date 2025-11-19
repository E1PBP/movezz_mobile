import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
// import 'core/network/cookie_request.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

void main() async {
  // Pastikan binding Flutter siap sebelum panggil async (SharedPreferences, dll.)
  WidgetsFlutterBinding.ensureInitialized();

  // Satu instance CookieRequest untuk seluruh aplikasi
  final cookieRequest = CookieRequest();
  await cookieRequest.init();

  runApp(
    // Provider global, nanti bisa diambil dari mana saja:
    // context.read<CookieRequest>()
    MultiProvider(
      providers: [
        Provider<CookieRequest>.value(value: cookieRequest),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,

      // Tema global
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,

      // Routing pakai factory yang sudah kamu buat di core/routing/app_router.dart
      onGenerateRoute: appRouteFactory,
      initialRoute: AppRoutes.login, // ganti kalau mau mulai dari splash/home
    );
  }
}
