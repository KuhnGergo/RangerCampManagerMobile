import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/localization_provider.dart';

class _Language {
  final String code;
  final String nativeName;
  final String englishName;

  const _Language({
    required this.code,
    required this.nativeName,
    required this.englishName,
  });
}

const _availableLanguages = [
  _Language(code: 'en', nativeName: 'English', englishName: 'English'),
  _Language(code: 'hu', nativeName: 'Magyar', englishName: 'Hungarian'),
];

Future<void> showLanguageSelectionDialog(BuildContext context, WidgetRef ref) {
  return showDialog<void>(
    context: context,
    builder: (context) => _LanguageSelectionDialog(ref: ref),
  );
}

class _LanguageSelectionDialog extends ConsumerWidget {
  final WidgetRef ref;

  const _LanguageSelectionDialog({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef innerRef) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = innerRef.watch(localeProvider);
    final currentCode = locale?.languageCode ?? 'en';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                'Select Language',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const Divider(height: 1),
            ..._availableLanguages.map((lang) {
              final isSelected = lang.code == currentCode;
              return InkWell(
                onTap: () {
                  innerRef
                      .read(localeProvider.notifier)
                      .setLocale(Locale(lang.code));
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang.nativeName,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.onSurface,
                                  ),
                            ),
                            if (lang.nativeName != lang.englishName)
                              Text(
                                lang.englishName,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check, color: colorScheme.primary, size: 20),
                    ],
                  ),
                ),
              );
            }),
            const Divider(height: 1),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
