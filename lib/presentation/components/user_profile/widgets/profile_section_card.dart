import 'package:flutter/material.dart';

/// Reusable card wrapper for profile sections.
class ProfileSectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget> children;

  const ProfileSectionCard({
    super.key,
    required this.title,
    this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
            ),

            Spacer(),
            if (icon != null) ...[
              Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}
