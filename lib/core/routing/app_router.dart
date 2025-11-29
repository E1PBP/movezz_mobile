import 'package:flutter/material.dart';
import 'package:movezz_mobile/features/auth/presentation/pages/auth_page.dart';
import 'package:movezz_mobile/features/auth/presentation/pages/onboarding_concentric.dart';
import 'package:movezz_mobile/core/widgets/main_navigation_page.dart';


class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String feeds = '/feeds';
  static const String profile = '/profile';
}

Route<dynamic> appRouteFactory(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.splash:
      return _buildRoute(settings, const ConcentricAnimationOnboarding());

    case AppRoutes.login:
      return _buildRoute(settings, const AuthPage());

    case AppRoutes.feeds:
      return _buildRoute(
        settings,
        const MainNavigationPage(),
      );

    case AppRoutes.profile:
      return _buildRoute(settings, const _SimpleScaffold(title: 'Profile'));

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
  return MaterialPageRoute(settings: settings, builder: (_) => child);
}

class _SimpleScaffold extends StatelessWidget {
  final String title;
  final Widget? body;

  const _SimpleScaffold({super.key, required this.title, this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), 
      automaticallyImplyLeading: false
      ),
      body: body ?? Center(child: Text(title)),
    );
  }
}
