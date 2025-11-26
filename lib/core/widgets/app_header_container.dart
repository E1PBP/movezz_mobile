import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../theme/app_theme.dart';
import '../config/app_config.dart';

class AppHeaderContainer extends StatelessWidget {
  final Widget child;

  const AppHeaderContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: context.width(),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: radiusOnly(
              topLeft: AppConfig.containerRadius,
              topRight: AppConfig.containerRadius,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: child,
        ),
        Container(
          height: 20,
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: radiusOnly(
              topLeft: AppConfig.containerRadius,
              topRight: AppConfig.containerRadius,
            ),
          ),
        ),
      ],
    );
  }
}
