import 'package:flutter/material.dart';
import 'package:mastercs_mobile/models/roles.dart';

/// Displays the member's role with the Role model icon and label.
class ProfileRoleBadge extends StatelessWidget {
  final String role;

  const ProfileRoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Role parsedRole;
    try {
      parsedRole = Role.fromString(role);
    } catch (_) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            parsedRole.icon,
            size: 16,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 6),
          Text(
            parsedRole.stringName,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
