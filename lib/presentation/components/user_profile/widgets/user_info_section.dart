import 'package:flutter/material.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/utils/phone_formatter.dart';

import 'profile_info_row.dart';
import 'profile_section_card.dart';

/// Displays the member's contact details: email, phone number.
class UserInfoSection extends StatelessWidget {
  final User user;

  const UserInfoSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Contact Information',
      children: [
        ProfileInfoRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: user.email,
        ),
        const SizedBox(height: 8),
        ProfileInfoRow(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: user.phoneNumber != null
              ? PhoneFormatter.formatReadable(user.phoneNumber!)
              : null,
        ),
        const SizedBox(height: 8),
        ProfileInfoRow(
          icon: Icons.contact_phone_outlined,
          label: 'Emergency Contact',
          value: user.emergencyContact,
        ),
      ],
    );
  }
}
