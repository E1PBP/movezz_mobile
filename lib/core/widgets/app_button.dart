import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../theme/app_theme.dart';
import '../config/app_config.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final double? width;
  final double height;
  final bool isLoading;
  final Color? color;
  final Color? textColor;
  final TextStyle? textStyle;
  final Widget? child;
  final RoundedRectangleBorder? shapeBorder;
  final double elevation;

  const AppButton({
    super.key,
    required this.text,
    this.onTap,
    this.width,
    this.height = 56,
    this.isLoading = false,
    this.color,
    this.textColor,
    this.textStyle,
    this.child,
    this.shapeBorder,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? context.width() - 32,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          foregroundColor: textColor ?? Colors.white,
          shape:
              shapeBorder ??
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConfig.commonRadius),
              ),
          elevation: elevation,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : child ??
                  Text(
                    text,
                    style:
                        textStyle ??
                        boldTextStyle(color: textColor ?? Colors.white),
                  ),
      ),
    );
  }
}

Widget appButton({
  required String text,
  required Function onTap,
  double? width,
  required BuildContext context,
  bool isLoading = false,
  Color? color,
  TextStyle? textStyle,
}) {
  return AppButton(
    shapeBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConfig.commonRadius),
    ),
    text: text,
    textStyle: textStyle ?? boldTextStyle(color: Colors.white),
    onTap: onTap as VoidCallback?,
    elevation: 0,
    color: color ?? AppColors.primary,
    width: width ?? context.width() - 32,
    height: 56,
    isLoading: isLoading,
  );
}
