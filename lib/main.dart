import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'features/messages/data/datasources/messages_remote_data_source.dart';
import 'features/messages/data/repositories/messages_repository.dart';
import 'features/messages/presentation/controllers/messages_controller.dart';

import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/repositories/profile_repository.dart';
import 'features/profile/presentation/controllers/profile_controller.dart';

import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

import 'features/feeds/data/datasources/feeds_remote_data_source.dart';
import 'features/feeds/data/repositories/feeds_repository.dart';
import 'features/feeds/presentation/controllers/feeds_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cookieRequest = CookieRequest();
  await cookieRequest.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<CookieRequest>.value(value: cookieRequest),
        ChangeNotifierProvider<AuthController>(
          create: (context) {
            final cookie = context.read<CookieRequest>();
            final remote = AuthRemoteDataSource(cookie);
            final repo = AuthRepositoryImpl(remote);
            return AuthController(repo);
          },
        ),
        ChangeNotifierProvider<FeedsController>(
          create: (context) {
            final cookie = context.read<CookieRequest>();
            final remote = FeedsRemoteDataSource(cookie);
            final repo = FeedsRepositoryImpl(remote);
            return FeedsController(repo);
          },
        ),
        ChangeNotifierProvider<MessagesController>(
          create: (context) {
            final cookie = context.read<CookieRequest>();
            final remote = MessagesRemoteDataSource(cookie);
            final repo = MessagesRepository(remote);
            return MessagesController(repo);
          },
        ),
        ChangeNotifierProvider<ProfileController>(
          create: (context) {
            final cookie = context.read<CookieRequest>();
            final remote = ProfileRemoteDataSource(cookie);
            final repo = ProfileRepository(remote);
            return ProfileController(repo);
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
