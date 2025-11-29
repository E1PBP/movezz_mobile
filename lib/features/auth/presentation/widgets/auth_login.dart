import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart' hide AppButton;
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/auth_controller.dart';
import 'package:movezz_mobile/core/routing/app_router.dart';

class AuthLogin extends StatefulWidget {
  final VoidCallback? onRegisterTap;

  const AuthLogin({Key? key, this.onRegisterTap}) : super(key: key);

  @override
  State<AuthLogin> createState() => _AuthLoginState();
}

class _AuthLoginState extends State<AuthLogin> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = context.read<AuthController>();

    final success = await authController.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final username =
          authController.currentUser?.username ??
          _usernameController.text.trim();
      context.showSnackBar('Login successful! Welcome back, $username.');

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.feeds, (route) => false);
    } else {
      final message =
          authController.error ??
          'Login failed. Please check your username and password.';
      context.showSnackBar(message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final isLoading = authController.isLoading;

    return Container(
      width: context.width(),
      color: context.cardColor,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              16.height,
              Text(
                'Welcome back!',
                style: boldTextStyle(size: 24),
              ).paddingSymmetric(horizontal: 16),
              8.height,
              Text(
                'You Have Been Missed For Long Time',
                style: secondaryTextStyle(weight: FontWeight.w500),
              ).paddingSymmetric(horizontal: 16),
              Container(
                child: Column(
                  children: [
                    30.height,
                    AppTextField(
                      controller: _usernameController,
                      textFieldType: TextFieldType.USERNAME,
                      textStyle: boldTextStyle(),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        contentPadding: const EdgeInsets.all(16),
                        labelStyle: secondaryTextStyle(weight: FontWeight.w600),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username cannot be empty';
                        }
                        return null;
                      },
                    ).paddingSymmetric(horizontal: 16),
                    16.height,
                    AppTextField(
                      controller: _passwordController,
                      textFieldType: TextFieldType.PASSWORD,
                      textStyle: boldTextStyle(),
                      suffixPasswordInvisibleWidget: const Icon(
                        Icons.visibility_off,
                        size: 20,
                        color: Colors.grey,
                      ).paddingSymmetric(vertical: 16, horizontal: 14),
                      suffixPasswordVisibleWidget: const Icon(
                        Icons.visibility,
                        size: 20,
                        color: Colors.grey,
                      ).paddingSymmetric(vertical: 16, horizontal: 14),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        contentPadding: const EdgeInsets.all(16),
                        labelStyle: secondaryTextStyle(weight: FontWeight.w600),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password cannot be empty';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ).paddingSymmetric(horizontal: 16),
                    16.height,
                    40.height,
                    AppButton(
                      text: isLoading ? 'Logging in...' : 'LOGIN',
                      onTap: isLoading ? null : _handleLogin,
                    ),
                    16.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t Have An Account?',
                          style: TextStyle(
                            fontFamily: AppConfig.robotoFont,
                            fontSize: 14,
                          ),
                        ),
                        4.width,
                        Text(
                          'Sign Up',
                          style: secondaryTextStyle(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ).onTap(
                          () => widget.onRegisterTap?.call(),
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                        ),
                      ],
                    ),
                    50.height,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
