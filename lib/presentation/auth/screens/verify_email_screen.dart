import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/api/api_exception_types.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/locale_toggle_button.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/theme_toggle_button.dart';
import 'package:mastercs_mobile/providers/auth/session_flow.dart';
import 'package:mastercs_mobile/providers/connection/connectivity_provider.dart';
import 'package:mastercs_mobile/providers/connection/status_enum.dart';
import 'package:mastercs_mobile/providers/theme_provider.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;
  final String password;

  const VerifyEmailScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen>
    with WidgetsBindingObserver {
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Try initial silent login when screen opens
    _performSilentLogin();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Try to login again when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _performSilentLogin();
    }
  }

  Future<void> _performSilentLogin() async {
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      // Check internet connection first
      final connectivityValue = ref.read(connectivityProvider).value;
      final isOnline =
          connectivityValue != null &&
          connectivityValue != InternetStatus.offline;

      if (!isOnline) {
        setState(() {
          _isVerifying = false;
          _errorMessage = 'No internet connection';
        });
        return;
      }

      // Attempt login
      await ref
          .read(sessionFlowProvider.notifier)
          .login(widget.email, widget.password);

      // If login succeeds, navigate to home/next screen
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on ForbiddenException catch (_) {
      // Email not verified yet - stay on this screen
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Email not verified.';
      });
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Email not verified.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Email verification icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primaryContainer,
                      ),
                      child: Icon(
                        Icons.mail_outline,
                        size: 60,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Verify Your Email',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Email address
                    Text(
                      widget.email,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Text(
                      'We\'ve sent a verification link to your email. Please verify your email to activate your account.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Retry verification button
                    OutlinedButton(
                      onPressed: _isVerifying ? null : _performSilentLogin,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        backgroundColor: colorScheme.surfaceContainer,
                        elevation: 2,
                        shadowColor: colorScheme.shadow,
                        side: BorderSide(
                          color: colorScheme.outline,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'Check Verification Status',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _isVerifying
                              ? colorScheme.onSurfaceVariant.withAlpha(160)
                              : colorScheme.primary,
                        ),
                      ),
                    ),
                    // Error message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _errorMessage!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.error),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Helper text
                    Text(
                      'The verification link will expire in 15 minutes.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withAlpha(160),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'After that the account will be deleted and you need to sign up again.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withAlpha(160),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
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
    );
  }
}
