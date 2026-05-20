import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/auth/utils/form_field_style.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool isPasswordVisible;
  final VoidCallback onToggleVisibility;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final VoidCallback? onSubmit;

  const PasswordField({
    super.key,
    required this.controller,
    required this.isPasswordVisible,
    required this.onToggleVisibility,
    required this.onChanged,
    this.errorText,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: !isPasswordVisible,
      keyboardType: TextInputType.visiblePassword,
      onChanged: (data) => onChanged(data),
      onSubmitted: onSubmit != null ? (_) => onSubmit!() : null,
      decoration: getFormFieldDecoration(
        labelText: 'Password',
        themeData: Theme.of(context),
        errorText: errorText,
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }
}
