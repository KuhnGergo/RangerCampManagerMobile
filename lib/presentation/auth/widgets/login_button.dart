import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';

class LoginButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onPressed;

  const LoginButton({
    super.key,
    required this.isSubmitting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onPressed,
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
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: isSubmitting
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: ThreeDotLoadingIndicator(
                    color: colorScheme.onPrimary,
                    orbitRadius: 8,
                    dotSize: 3,
                    spinDuration: const Duration(milliseconds: 1000),
                  ),
                )
              : Text(
                  'Login',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
