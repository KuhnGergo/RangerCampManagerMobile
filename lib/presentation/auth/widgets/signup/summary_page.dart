import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/signup/signup_page_container.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/signup/review_entry.dart';
import 'package:mastercs_mobile/utils/phone_formatter.dart';

class SummaryPage extends StatelessWidget {
  final String email;
  final String username;
  final String? phoneNumber;
  final String? emergencyNumber;
  final Function(int) onEditPage;
  final Future<void> Function() onSignup;
  final VoidCallback onBack;
  final bool isLoading;
  final bool isOnline;
  final VoidCallback? onShowOfflineToast;

  const SummaryPage({
    super.key,
    required this.email,
    required this.username,
    this.phoneNumber,
    this.emergencyNumber,
    required this.onEditPage,
    required this.onSignup,
    required this.onBack,
    this.isLoading = false,
    this.isOnline = true,
    this.onShowOfflineToast,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SignupPageContainer(
      onNext: onSignup,
      onBack: onBack,
      isLoading: isLoading,
      isOnline: isOnline,
      onShowOfflineToast: onShowOfflineToast,
      nextButtonText: 'Sign Up',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Review Your Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            child: Column(
              children: [
                // Email
                ReviewEntry(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: email,
                  onEdit: null, // Email can't be edited
                ),
                const SizedBox(height: 16),

                // Username
                ReviewEntry(
                  icon: Icons.person_outline,
                  label: 'Username',
                  value: username,
                  onEdit: () => onEditPage(0),
                ),
                const SizedBox(height: 16),

                // Password
                ReviewEntry(
                  icon: Icons.lock_outline,
                  label: 'Password',
                  value: '••••••••',
                  onEdit: () => onEditPage(1),
                ),
                const SizedBox(height: 16),

                // Phone Number
                ReviewEntry(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: phoneNumber != null && phoneNumber!.isNotEmpty
                      ? PhoneFormatter.formatReadable(phoneNumber!)
                      : 'Not set',
                  onEdit: () => onEditPage(2),
                  isOptional: true,
                ),
                const SizedBox(height: 16),

                // Emergency Number
                ReviewEntry(
                  icon: Icons.emergency_outlined,
                  label: 'Emergency Contact',
                  value: emergencyNumber ?? 'Not set',
                  onEdit: () => onEditPage(3),
                  isOptional: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
