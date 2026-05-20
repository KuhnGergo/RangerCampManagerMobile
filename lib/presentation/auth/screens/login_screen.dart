import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/auth/controllers/login_controller.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/back_texted_button.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/disabled_email_field.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/forgot_password_button.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/forgot_password_sheet.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/locale_toggle_button.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/login_button.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/password_field.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/theme_toggle_button.dart';
import 'package:mastercs_mobile/providers/theme_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController(
      text: ref.read(loginController).password,
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginController);
    final stateController = ref.read(loginController.notifier);

    final colorScheme = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    ref.listen<LoginState>(loginController, (previous, next) {
      if (next.isLoginSuccessful) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    void showForgotPasswordBottomSheet() {
      showModalBottomSheet(
        context: context,
        isDismissible: true,
        enableDrag: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ForgotPasswordSheet(
          email: state.email,
          lastEmailSentTime: state.lastEmailSentTime,
          onEmailSent: stateController.setSentTime,
        ),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      DisabledEmailField(
                        email: state.email,
                        onEdit: () => Navigator.pop(context),
                      ),

                      const SizedBox(height: 16),

                      PasswordField(
                        controller: passwordController,
                        isPasswordVisible: state.isPasswordVisible,
                        onToggleVisibility:
                            stateController.togglePasswordVisibility,
                        onChanged: stateController.setPassword,
                        errorText: state.errorText,
                        onSubmit: stateController.submit,
                      ),

                      const SizedBox(height: 4),

                      ForgotPasswordButton(
                        onPressed: showForgotPasswordBottomSheet,
                      ),

                      const SizedBox(height: 4),

                      LoginButton(
                        isSubmitting: state.isSubmitting,
                        onPressed: stateController.submit,
                      ),

                      const SizedBox(height: 16),

                      BackTextedButton(onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                ),
              ),
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
