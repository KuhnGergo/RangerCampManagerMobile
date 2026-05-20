import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/auth/controllers/auth_controller.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/auth_header.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/email_form.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/email_suffix_bar.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/locale_toggle_button.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/theme_toggle_button.dart';
import 'package:mastercs_mobile/l10n/localization_extension.dart';
import 'package:mastercs_mobile/providers/theme_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final Object? error;

  const AuthScreen({super.key, this.error});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late final TextEditingController emailController;

  @override
  void initState() {
    super.initState();

    emailController = TextEditingController(
      text: ref.read(authController).email,
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthState state = ref.watch(authController);
    final AuthController stateController = ref.read(authController.notifier);

    ref.listen(authController, (previous, next) {
      final userExistence = next.userExistence;

      if (userExistence == UserExitstence.exists) {
        Navigator.pushNamed(context, '/login');
        // Reset state after navigation
        stateController.resetUserExistence();
      } else if (userExistence == UserExitstence.notExists) {
        Navigator.pushNamed(context, '/signup');
        // Reset state after navigation
        stateController.resetUserExistence();
      }

      if (next.email.isEmpty && previous?.email.isNotEmpty == true) {
        stateController.setEmail(emailController.text);
        return;
      }
      if (previous?.email != next.email && emailController.text != next.email) {
        emailController.text = next.email;
      }
    });

    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Stack(
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AuthHeader(
                              title: context.l10n.auth_welcome,
                              subtitle: context.l10n.auth_enter_email,
                            ),
                            const SizedBox(height: 32),
                            EmailForm(
                              controller: emailController,
                              errorText: state.errorMessage,
                              onSubmit: stateController.submit,
                              isSubmitting: state.isSubmitting,
                              onChanged: stateController.setEmail,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                EmailSuffixBar(
                  controller: emailController,
                  onSuffixTap: stateController.appendSuffix,
                  bottomInset: bottomInset,
                ),
              ],
            ),
            Positioned(
              top: 16,
              left: 16,
              child: SafeArea(
                child: Row(
                  children: [
                    ThemeToggleButton(isDarkMode: isDarkMode),
                    const SizedBox(width: 16),
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
