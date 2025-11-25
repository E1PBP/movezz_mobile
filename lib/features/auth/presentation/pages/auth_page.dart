import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_header_container.dart';
import '../../../../core/config/app_config.dart';

import '../widgets/auth_login.dart';
import '../widgets/auth_register.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
    });
  }

  @override
  void dispose() {

    super.dispose();
  }

  Widget _getFragment() {
    if (selectedIndex == 0) {
      return AuthLogin(
        onRegisterTap: () {
          setState(() => selectedIndex = 1);
        },
      );
    } else {
      return AuthRegister(
        onLoginTap: () {
          setState(() => selectedIndex = 0);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: svGetScaffoldColor(),
      body: Column(
        children: [
          SizedBox(height: context.statusBarHeight + 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              8.width,
              Text(
                AppConfig.appName,
                style: primaryTextStyle(
                  color: AppColors.primary,
                  size: 28,
                  weight: FontWeight.w800,
                  fontFamily: AppConfig.robotoFont,
                ),
              ),
            ],
          ),
          40.height,
          AppHeaderContainer(
            // context: context,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  child: Text(
                    'LOGIN',
                    style: boldTextStyle(
                      color: selectedIndex == 0 ? Colors.white : Colors.white54,
                      size: 16,
                    ),
                  ),
                  onPressed: () {
                    setState(() => selectedIndex = 0);
                  },
                ),
                TextButton(
                  child: Text(
                    'SIGNUP',
                    style: boldTextStyle(
                      color: selectedIndex == 1 ? Colors.white : Colors.white54,
                      size: 16,
                    ),
                  ),
                  onPressed: () {
                    setState(() => selectedIndex = 1);
                  },
                ),
              ],
            ),
          ),
          _getFragment().expand(),
        ],
      ),
    );
  }
}
