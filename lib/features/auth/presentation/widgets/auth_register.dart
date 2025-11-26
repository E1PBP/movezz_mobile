import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart' hide AppButton;
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/extensions.dart';
import '../controllers/auth_controller.dart';
import 'package:movezz_mobile/core/routing/app_router.dart';

class AuthRegister extends StatefulWidget {
  final VoidCallback? onLoginTap;

  const AuthRegister({Key? key, this.onLoginTap}) : super(key: key);

  @override
  State<AuthRegister> createState() => _AuthRegisterState();
}

class _AuthRegisterState extends State<AuthRegister> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = context.read<AuthController>();

    final success = await authController.register(
      _usernameController.text.trim(),
      '',
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final username =
          authController.currentUser?.username ??
          _usernameController.text.trim();

      context.showSnackBar('Welcome, $username!');

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.feeds, (route) => false);
    } else {
      final message =
          authController.error ?? 'Registration failed. Please try again.';
      context.showSnackBar(message);
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
                'Join ${AppConfig.appName}',
                style: boldTextStyle(size: 24),
              ).paddingSymmetric(horizontal: 16),
              8.height,
              Text(
                'Create your account to get started!',
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
                        if (value.trim().length < 3) {
                          return 'Username must be at least 3 characters';
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
                    AppTextField(
                      controller: _confirmPasswordController,
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
                        labelText: 'Confirm Password',
                        contentPadding: const EdgeInsets.all(16),
                        labelStyle: secondaryTextStyle(weight: FontWeight.w600),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm password cannot be empty';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ).paddingSymmetric(horizontal: 16),
                    16.height,
                    40.height,
                    AppButton(
                      text: isLoading ? 'Creating Account...' : 'SIGN UP',
                      onTap: isLoading ? null : _handleRegister,
                    ),
                    16.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(
                            fontFamily: AppConfig.robotoFont,
                            fontSize: 14,
                          ),
                        ),
                        4.width,
                        Text(
                          'Sign In',
                          style: secondaryTextStyle(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ).onTap(
                          () => widget.onLoginTap?.call(),
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
