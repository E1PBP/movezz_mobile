import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // CookieRequest global untuk session Django (login/logout)
  final cookieRequest = CookieRequest();
  await cookieRequest.init();

  runApp(
    MultiProvider(
      providers: [
        // Provider untuk CookieRequest
        Provider<CookieRequest>.value(value: cookieRequest),

        // Provider untuk AuthController (harus pakai ChangeNotifierProvider!)
        ChangeNotifierProvider<AuthController>(
          create: (context) {
            final cookie = context.read<CookieRequest>();
            final remote = AuthRemoteDataSource(cookie);
            final repo = AuthRepositoryImpl(remote);
            return AuthController(repo);
          },
        ),
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
      theme: AppTheme.light,
      onGenerateRoute: appRouteFactory,
      initialRoute: AppRoutes.splash,
    );
  }
}
