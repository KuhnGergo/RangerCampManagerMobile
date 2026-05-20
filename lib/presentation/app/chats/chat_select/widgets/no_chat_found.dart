import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/actions/chat_actions_provider.dart';
import 'package:mastercs_mobile/providers/data/selected_camp_id_provider.dart';

class NoChatFound extends ConsumerWidget {
  const NoChatFound({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                color: colorScheme.primaryContainer.withAlpha(0x33),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 72,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'No Conversations Found',
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Text(
              'Everybody deserves a conversation. ',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withAlpha(0xCC),
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'Try refreshing!',
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
                disabledBackgroundColor: colorScheme.primary.withAlpha(0x66),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: ref.watch(chatActionsProvider).isLoading ? 0 : 1,
                    child: Text(
                      'Refresh Chats',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimary,
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
                        valueColor: AlwaysStoppedAnimation(colorScheme.surface),
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            // TODO [no_chat_found] l10n
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
