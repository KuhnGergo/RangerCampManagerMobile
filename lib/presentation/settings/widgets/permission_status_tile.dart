import 'package:flutter/material.dart';
import 'package:mastercs_mobile/utils/progress_color_utils.dart';

/// A settings tile that displays a permission status with a warning/check trailing icon.
class PermissionStatusTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isGranted;

  const PermissionStatusTile({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.isGranted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (!isGranted)
                Icon(
                  Icons.warning_amber_rounded,
                  size: 20,
                  color: colorScheme.error,
                )
              else
                Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: ProgressColorUtils.toColor(1.0),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
