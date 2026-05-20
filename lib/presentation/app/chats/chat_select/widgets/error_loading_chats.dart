import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/actions/chat_actions_provider.dart';
import 'package:mastercs_mobile/providers/data/selected_camp_id_provider.dart';

class ErrorLoadingChats extends ConsumerWidget {
  final Object error;
  const ErrorLoadingChats({super.key, required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    log('Error loading chats: $error');

    ref.listen(chatActionsProvider, (_, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Chat refresh failed'),
              backgroundColor: colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
        },
      );
    });

    Future<void> refreshChats() async {
      final campId = ref.read(selectedCampIdProvider).value;
      await ref.read(chatActionsProvider.notifier).refreshChats(campId);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withAlpha(200),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.priority_high_rounded,
                size: 72,
                color: colorScheme.error,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'Error Loading Conversations',
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Text(
              'Unexpected error occurred while loading chats.',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withAlpha(0xCC),
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'Try again later!',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withAlpha(0xCC),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Refresh Button
            FilledButton(
              onPressed: ref.watch(chatActionsProvider).isLoading
                  ? null
                  : refreshChats,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                disabledBackgroundColor: colorScheme.error.withAlpha(0x66),
                backgroundColor: colorScheme.error,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: ref.watch(chatActionsProvider).isLoading ? 0 : 1,
                    child: Text(
                      'Refresh Chats',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onError,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (ref.watch(chatActionsProvider).isLoading)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation(colorScheme.error),
                      ),
                    ),
                ],
              ),
            ),

            const Spacer(),
            // TODO [error_loading_chats] l10n
            Text(
              'If the problem persists, please check your network connection or contact support.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withAlpha(0x99),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
