import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../theme/app_theme.dart';
import '../config/app_config.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final Widget? prefix;
  final Widget? prefixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.hintStyle,
    this.labelStyle,
    this.prefix,
    this.prefixIcon,
    this.contentPadding,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(vertical: 12),
        labelText: labelText,
        hintText: hintText,
        hintStyle: hintStyle ?? secondaryTextStyle(),
        labelStyle: labelStyle ?? secondaryTextStyle(),
        prefix: prefix,
        prefixIcon: prefixIcon,
        errorMaxLines: 2,
        errorStyle: primaryTextStyle(color: Colors.red, size: 12),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
    );
  }
}