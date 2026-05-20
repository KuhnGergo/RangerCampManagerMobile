import 'package:flutter/material.dart';

InputDecoration getFormFieldDecoration({
  required String labelText,
  required ThemeData themeData,
  Widget? suffixIcon,
  String? errorText,
  bool? enabled = true,
  String? hintText,
  Widget? prefixIcon,
  Color? prefixIconColor,
  Color? suffixIconColor,
  EdgeInsetsGeometry? padding,
}) {
  double restBorderWidth = 2.5;
  double focusedBorderWidth = 4;
  final hasError = errorText != null;

  return InputDecoration(
    labelText: labelText,
    errorMaxLines: 2,
    hintText: hintText ?? labelText,
    prefixIcon: prefixIcon,
    // ignore: prefer_if_null_operators
    prefixIconColor: prefixIconColor != null
        ? prefixIconColor
        : hasError
        ? themeData.colorScheme.error
        : enabled == true
        ? themeData.colorScheme.primary
        : themeData.colorScheme.onSurface.withAlpha(78),
    suffixIcon: suffixIcon,
    // ignore: prefer_if_null_operators
    suffixIconColor: suffixIconColor != null
        ? suffixIconColor
        : hasError
        ? themeData.colorScheme.error
        : enabled == true
        ? themeData.colorScheme.primary
        : themeData.colorScheme.onSurface.withAlpha(78),
    filled: false,
    errorText: errorText,
    labelStyle: TextStyle(
      color: hasError
          ? themeData.colorScheme.error
          : enabled == true
          ? themeData.colorScheme.primary
          : themeData.colorScheme.onSurface.withAlpha(78),
    ),
    focusColor: hasError
        ? themeData.colorScheme.error
        : themeData.colorScheme.primary,

    hintStyle: TextStyle(color: themeData.colorScheme.onSurface.withAlpha(128)),
    contentPadding:
        padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 20),

    floatingLabelBehavior: FloatingLabelBehavior.always,

    enabledBorder: getInputBorder(
      hasError
          ? themeData.colorScheme.error
          : enabled == true
          ? themeData.colorScheme.primary
          : themeData.colorScheme.onSurface.withAlpha(78),
      restBorderWidth,
    ),
    focusedBorder: getInputBorder(
      hasError
          ? themeData.colorScheme.error
          : enabled == true
          ? themeData.colorScheme.primary
          : themeData.colorScheme.onSurface.withAlpha(78),
      focusedBorderWidth,
    ),
    errorBorder: getInputBorder(themeData.colorScheme.error, restBorderWidth),
    focusedErrorBorder: getInputBorder(
      themeData.colorScheme.error,
      focusedBorderWidth,
    ),
    disabledBorder: getInputBorder(
      themeData.colorScheme.onSurface.withAlpha(78),
      restBorderWidth,
    ),
  );
}

OutlineInputBorder getInputBorder(Color color, double width) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide(color: color, width: width),
  );
}
