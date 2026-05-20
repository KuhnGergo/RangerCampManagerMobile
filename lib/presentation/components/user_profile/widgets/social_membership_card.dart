import 'package:flutter/material.dart';

/// A generic card that indicates whether a member belongs to a social entity
/// (e.g. a group or room) without revealing any specific details.
class SocialMembershipCard extends StatelessWidget {
  final bool hasMembership;
  final String label;
  final IconData icon;

  const SocialMembershipCard({
    super.key,
    required this.hasMembership,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = hasMembership
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: hasMembership
            ? colorScheme.primaryContainer.withValues(alpha: 0.4)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  hasMembership ? 'In a $label' : 'Not in a $label',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            hasMembership
                ? Icons.check_circle_outline
                : Icons.remove_circle_outline,
            size: 24,
            color: color,
          ),
        ],
      ),
    );
  }
}
