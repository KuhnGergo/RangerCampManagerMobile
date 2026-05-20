import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/auth/controllers/signup_controller.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/locale_toggle_button.dart';
import 'package:mastercs_mobile/presentation/components/error/error_snackbar.dart';

import 'package:mastercs_mobile/presentation/auth/widgets/signup/emergency_number_page.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/signup/password_page.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/signup/signup_page_indicator.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/signup/summary_page.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/signup/username_page.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/signup/phone_number_page.dart';
import 'package:mastercs_mobile/presentation/auth/screens/verify_email_screen.dart';

import 'package:mastercs_mobile/presentation/auth/widgets/theme_toggle_button.dart';

import 'package:mastercs_mobile/providers/theme_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: ref.read(signupController).currentPage,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showOfflineToast() {
    if (!mounted) {
      return;
    }
    showError(context, 'No internet connection');
    ref.read(signupController.notifier).updateForErrorToast();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupController);
    final stateController = ref.read(signupController.notifier);

    ref.listen<SignupState>(signupController, (previous, next) {
      if (previous?.isCreatingAccount == true &&
          next.isCreatingAccount == false &&
          next.isLoginSuccessful == false) {
        if (next.isOnline != null && !next.isOnline!) {
          showError(context, 'Cannot create account while offline.');
        }
      }

      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        showError(
          context,
          'Failed to create account',
          extendedText: next.errorMessage!,
        );
        stateController.clearErrorMessage();
      }

      if (next.isLoginSuccessful) {
        // Navigate to verify email screen with email and password
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                VerifyEmailScreen(email: state.email, password: state.password),
          ),
        );
      }

      // Handle page navigation when state changes
      if (previous != null && previous.currentPage != next.currentPage) {
        _pageController.animateToPage(
          next.currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    final colorScheme = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          'Create Account',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.email,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 24),
                        SignupPageIndicator(
                          currentPage: state.currentPage,
                          totalPages: SignupState.dataCount,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        UsernamePage(
                          initialValue: state.username,
                          isOnline: state.isOnline ?? true,
                          onNext: (username) {
                            stateController.saveAndNextUsername(username);
                          },
                          onBack: () => Navigator.pop(context),
                          onBackToSummary: state.returnToSummaryPage
                              ? stateController.goToSummaryPage
                              : null,
                          onShowOfflineToast: _showOfflineToast,
                        ),
                        PasswordPage(
                          initialPassword: state.password,
                          isOnline: state.isOnline ?? true,
                          onNext: (password) {
                            stateController.saveAndNextPassword(password);
                          },
                          onBack: stateController.previousPage,
                          onBackToSummary: state.returnToSummaryPage
                              ? stateController.goToSummaryPage
                              : null,
                          onShowOfflineToast: _showOfflineToast,
                        ),
                        PhoneNumberPage(
                          initialValue: state.phoneNumber,
                          isOnline: state.isOnline ?? true,
                          onNext: (phone) {
                            stateController.saveAndNextPhoneNumber(phone);
                          },
                          onSkip: stateController.nextPage,
                          onBack: stateController.previousPage,
                          onBackToSummary: state.returnToSummaryPage
                              ? stateController.goToSummaryPage
                              : null,
                          onShowOfflineToast: _showOfflineToast,
                        ),
                        EmergencyNumberPage(
                          initialValue: state.emergencyContact,
                          isOnline: state.isOnline ?? true,
                          onFinish: (emergency) async {
                            stateController.saveAndNextEmergencyContact(
                              emergency,
                            );
                          },
                          onSkip: () async => stateController.nextPage(),
                          onBack: stateController.previousPage,
                          onBackToSummary: state.returnToSummaryPage
                              ? stateController.goToSummaryPage
                              : null,
                          onShowOfflineToast: _showOfflineToast,
                        ),
                        SummaryPage(
                          email: state.email,
                          username: state.username,
                          phoneNumber: state.phoneNumber,
                          emergencyNumber: state.emergencyContact,
                          onEditPage: (pageIndex) =>
                              stateController.goToPage(pageIndex),
                          onSignup: stateController.createAccount,
                          onBack: stateController.previousPage,
                          isLoading: state.isCreatingAccount,
                          isOnline: state.isOnline ?? true,
                          onShowOfflineToast: _showOfflineToast,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: SafeArea(
                child: Column(
                  children: [
                    ThemeToggleButton(isDarkMode: isDarkMode),
                    const SizedBox(height: 16),
                    LocaleToggleButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
