import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/auth/utils/form_field_style.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';

class EmailForm extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final VoidCallback onSubmit;
  final bool isSubmitting;
  final ValueChanged<String> onChanged;

  const EmailForm({
    super.key,
    required this.controller,
    this.errorText,
    required this.onSubmit,
    required this.isSubmitting,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        TextField(
          controller: controller,
          autofillHints: const [AutofillHints.email],
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => onChanged(value),
          onSubmitted: isSubmitting ? null : (_) => onSubmit(),
          decoration: getFormFieldDecoration(
            labelText: 'Email Address',
            themeData: Theme.of(context),
            errorText: errorText,
            suffixIcon: const Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 2,
              disabledBackgroundColor: colorScheme.primary.withAlpha(128),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              child: isSubmitting
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: ThreeDotLoadingIndicator(
                        color: colorScheme.onPrimary,
                        dotSize: 3,
                        spinDuration: const Duration(milliseconds: 800),
                      ),
                    )
                  : Text(
                      'Continue',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
