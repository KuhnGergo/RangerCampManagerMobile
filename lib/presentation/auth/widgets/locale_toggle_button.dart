import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/localization_provider.dart';

class LocaleToggleButton extends ConsumerWidget {
  const LocaleToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHu = ref.watch(
      localeProvider.select((locale) => locale?.languageCode == 'hu'),
    );
    final onToggle = ref.read(localeProvider.notifier).toggleLocale;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Text(
            isHu == true ? '🇭🇺' : '🇺🇸',
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
