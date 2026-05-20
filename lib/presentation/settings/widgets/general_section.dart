import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/components/user_profile/widgets/profile_section_card.dart';
import 'package:mastercs_mobile/presentation/settings/screens/help_support_screen.dart';
import 'package:mastercs_mobile/presentation/settings/widgets/section_action_tile.dart';

class GeneralSection extends StatelessWidget {
  const GeneralSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'General',
      children: [
        SectionActionTile(
          icon: Icons.help_outline_rounded,
          label: 'Help & Support',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
            );
          },
        ),
      ],
    );
  }
}
