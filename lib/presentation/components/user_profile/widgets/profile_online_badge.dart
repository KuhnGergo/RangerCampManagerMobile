import 'package:flutter/material.dart';

/// Shows an online/offline indicator with "last seen" info.
class ProfileOnlineBadge extends StatelessWidget {
  final bool isOnline;
  final DateTime? lastSeenAt;

  const ProfileOnlineBadge({
    super.key,
    required this.isOnline,
    this.lastSeenAt,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? Colors.green : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          color.withAlpha(80),
          Theme.of(context).scaffoldBackgroundColor,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color.alphaBlend(
            color.withAlpha(150),
            Theme.of(context).scaffoldBackgroundColor,
          ),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            _label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String get _label {
    if (isOnline) return 'Online';
    if (lastSeenAt != null) return 'Last seen ${_formatLastSeen(lastSeenAt!)}';
    return 'Offline';
  }

  static String _formatLastSeen(DateTime lastSeen) {
    final difference = DateTime.now().difference(lastSeen);
    if (difference.inMinutes < 1) return 'just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return 'over a week ago';
  }
}
