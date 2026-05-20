import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/components/user_profile/widgets/profile_info_row.dart';
import 'package:mastercs_mobile/presentation/components/user_profile/widgets/profile_section_card.dart';
import 'package:mastercs_mobile/presentation/settings/widgets/language_selection_dialog.dart';
import 'package:mastercs_mobile/presentation/settings/widgets/theme_mode_long_toggle.dart';
import 'package:mastercs_mobile/providers/localization_provider.dart';

class PreferencesSection extends ConsumerWidget {
  const PreferencesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final language = locale?.languageCode.toUpperCase() ?? 'EN';

    return ProfileSectionCard(
      title: 'Preferences',
      children: [
        ThemeModeLongToggle(
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
        ),
        const SizedBox(height: 8),
        ProfileInfoRow(
          icon: Icons.language,
          label: "Language",
          value: language,
          onTap: () => showLanguageSelectionDialog(context, ref),
        ),
      ],
    );
  }
}
