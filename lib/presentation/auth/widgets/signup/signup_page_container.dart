import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/back_texted_button.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';

class SignupPageContainer extends StatelessWidget {
  final Widget? header;
  final Widget body;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final VoidCallback onBack;
  final VoidCallback? onBackToSummary;
  final VoidCallback? onShowOfflineToast;
  final bool isLoading;
  final String nextButtonText;
  final bool showSkip;
  final bool hasValue;
  final bool isOnline;

  const SignupPageContainer({
    super.key,
    this.header,
    required this.body,
    this.onNext,
    this.onSkip,
    required this.onBack,
    this.onBackToSummary,
    this.onShowOfflineToast,
    this.isLoading = false,
    this.nextButtonText = 'Next',
    this.showSkip = false,
    this.hasValue = false,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (header != null) header!,
                body,
                const SizedBox(height: 16),
                SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      if (onNext != null && (hasValue || !showSkip))
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : onNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 2,
                              disabledBackgroundColor: colorScheme.primary
                                  .withAlpha(128),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: ThreeDotLoadingIndicator(
                                        dotSize: 4,
                                        color: colorScheme.primary,
                                        orbitRadius: 9,
                                        spinDuration: const Duration(
                                          seconds: 1,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      nextButtonText,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onPrimary,
                                          ),
                                    ),
                            ),
                          ),
                        ),
                      if (showSkip && onSkip != null && !hasValue) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: isLoading ? null : onSkip,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              side: BorderSide(color: colorScheme.outline),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              child: Text(
                                nextButtonText == 'Create Account'
                                    ? 'Skip & Create Account'
                                    : 'Skip',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              BackTextedButton(onPressed: onBack),
                              const SizedBox(width: 8),
                              if (!isOnline)
                                Tooltip(
                                  message: 'No internet connection',
                                  child: GestureDetector(
                                    onTap: onShowOfflineToast,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: colorScheme.errorContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.wifi_off,
                                        size: 16,
                                        color: colorScheme.onErrorContainer,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (onBackToSummary != null)
                            GestureDetector(
                              onTap: isLoading ? null : onBackToSummary,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'To Summary',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color:
                                                colorScheme.onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward,
                                      size: 16,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
