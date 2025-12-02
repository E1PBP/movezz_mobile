import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:nb_utils/nb_utils.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/messages/data/datasources/messages_remote_data_source.dart';
import 'features/messages/data/repositories/messages_repository.dart';
import 'features/messages/presentation/controllers/messages_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await initialize();

  final cookieRequest = CookieRequest();
  await cookieRequest.init();

  bool hasSeenOnboarding = getBoolAsync(
    'hasSeenOnboarding',
    defaultValue: false,
  );

  String initialRoute;

  if (hasSeenOnboarding) {
    if (cookieRequest.loggedIn) {
      initialRoute = AppRoutes.feeds;
    } else {
      initialRoute = AppRoutes.login;
    }
  } else {
    initialRoute = AppRoutes.splash;
  }

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
        ChangeNotifierProvider<MessagesController>(
          create: (context) {
            final cookie = context.read<CookieRequest>();
            final remote = MessagesRemoteDataSource(cookie);
            final repo = MessagesRepository(remote);
            return MessagesController(repo);
          },
        ),
      ],
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      onGenerateRoute: appRouteFactory,
      initialRoute: initialRoute,
    );
  }
}
