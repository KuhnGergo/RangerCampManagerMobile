import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/camp_selection/widgets/primary_action.dart';
import 'package:mastercs_mobile/presentation/components/error/error_snackbar.dart';
import 'package:mastercs_mobile/presentation/components/widgets/account_avatar.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';
import 'package:mastercs_mobile/providers/actions/camp_actions_provider.dart';

class AddCampScreen extends ConsumerStatefulWidget {
  const AddCampScreen({super.key});

  @override
  ConsumerState<AddCampScreen> createState() => _AddCampScreenState();
}

class _AddCampScreenState extends ConsumerState<AddCampScreen> {
  bool isLoading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AccountAvatar(),
        ),
        title: Text(
          'Your First Camp',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: ThreeDotLoadingIndicator(
                        color: colorScheme.onSurface,
                        dotSize: 3,
                        spinDuration: const Duration(milliseconds: 800),
                        orbitRadius: 7,
                      ),
                    )
                  : const Icon(Icons.refresh, size: 24),
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });
                      try {
                        await ref
                            .read(campActionsProvider.notifier)
                            .refreshCamps();
                      } catch (e) {
                        if (context.mounted) {
                          setState(() {
                            errorMessage = 'Failed to refresh camps';
                          });
                          showError(
                            context,
                            'Failed to refresh camps',
                            extendedText: e.toString(),
                            stackTrace: StackTrace.current,
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                    },
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cottage,
                  size: 80,
                  color: colorScheme.onSurfaceVariant.withAlpha(100),
                ),
                const SizedBox(height: 24),
                Text(
                  'Your camp list is empty',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Join or create a camp to get started.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),
                PrimaryAction(
                  icon: Icons.qr_code_scanner,
                  title: 'Join with QR Code',
                  subtitle: 'Scan a camp QR code',
                  onTap: () {
                    Navigator.of(context).pushNamed('/join-camp-qr');
                  },
                ),
                const SizedBox(height: 16),
                PrimaryAction(
                  icon: Icons.pin,
                  title: 'Join with Code',
                  subtitle: 'Enter a camp join code',
                  onTap: () {
                    Navigator.of(context).pushNamed('/join-camp');
                  },
                ),
                const SizedBox(height: 16),
                PrimaryAction(
                  icon: Icons.add_circle_outline,
                  title: 'Create Your Own Camp',
                  subtitle: 'Start a new camp from scratch',
                  onTap: () {
                    Navigator.of(context).pushNamed('/create-camp');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
