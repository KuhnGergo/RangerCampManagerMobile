import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/data/typing_users_provider.dart';

/// Widget that displays typing indicators for users currently typing in a chat
class TypingIndicator extends ConsumerWidget {
  final String chatId;

  const TypingIndicator({super.key, required this.chatId});

  // TODO [typing_indicator] l10n
  String _buildTypingText(List<String> names) {
    if (names.isEmpty) return '';

    if (names.length == 1) {
      return '${names[0]} is typing...';
    } else if (names.length == 2) {
      return '${names[0]} and ${names[1]} are typing...';
    } else {
      return '${names[0]}, ${names[1]}, and ${names.length - 2} others are typing...';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typingUsers = ref.watch(typingUsersListProvider(chatId));

    if (typingUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final names = typingUsers.map((user) => user.name).toList();
    final typingText = _buildTypingText(names);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _TypingAnimation(colorScheme: colorScheme),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              typingText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated dots to indicate typing
class _TypingAnimation extends StatefulWidget {
  final ColorScheme colorScheme;

  const _TypingAnimation({required this.colorScheme});

  @override
  State<_TypingAnimation> createState() => _TypingAnimationState();
}

class _TypingAnimationState extends State<_TypingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) {
              // Calculate delay for each dot
              final delay = index * 0.2;
              final value = (_controller.value - delay) % 1.0;

              // Scale animation
              final scale = value < 0.5
                  ? 1.0 + (value * 0.6)
                  : 1.3 - ((value - 0.5) * 0.6);

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.colorScheme.onSurfaceVariant,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
