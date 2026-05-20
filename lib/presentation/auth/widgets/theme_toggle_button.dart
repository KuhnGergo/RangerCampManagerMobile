import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/theme_provider.dart';

class ThemeToggleButton extends ConsumerWidget {
  final bool isDarkMode;

  const ThemeToggleButton({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = ref.watch(themeProvider.notifier);

    void onToggle() {
      theme.toggleTheme();
    }

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: colorScheme.onSurface,
            size: 24,
          ),
        ),
      ),
    );
  }
}
