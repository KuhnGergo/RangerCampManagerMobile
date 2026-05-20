import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/auth/utils/form_field_style.dart';

class DisabledEmailField extends StatelessWidget {
  final String email;
  final VoidCallback onEdit;

  const DisabledEmailField({
    super.key,
    required this.email,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: TextField(
            enabled: false,
            controller: TextEditingController(text: email),
            decoration: getFormFieldDecoration(
              labelText: 'Email Address',
              themeData: Theme.of(context),
              suffixIcon: const Icon(Icons.email_outlined),
              enabled: false,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Icon(Icons.edit, color: colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      ],
    );
  }
}
