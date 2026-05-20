/// Formats a DateTime into a human-readable "time until due" string.
/// Examples: "Today", "Tomorrow", "3 days", "2 weeks", "Overdue", "—"
String formatTimeUntilDue(DateTime? dueDate) {
  if (dueDate == null) return '—';

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final difference = due.difference(today).inDays;

  // TODO: [time_utils] l10n
  if (difference < 0) return 'Overdue';
  if (difference == 0) return 'Today';
  if (difference == 1) return 'Tomorrow';
  if (difference < 7) return '$difference days';
  if (difference < 30) {
    final weeks = (difference / 7).floor();
    return '$weeks week${weeks == 1 ? '' : 's'}';
  }
  if (difference < 365) {
    final months = (difference / 30).floor();
    return '$months month${months == 1 ? '' : 's'}';
  }
  final years = (difference / 365).floor();
  return '$years year${years == 1 ? '' : 's'}';
}

/// Formats a DateTime into a compact "time ago" string for small displays.
/// Examples: "30s", "5m", "2h", "3d"
String formatTimeAgoCompact(DateTime? dateTime) {
  if (dateTime == null) return '';
  final localDateTime = dateTime.toLocal();
  final diff = DateTime.now().difference(localDateTime);
  if (diff.inSeconds < 60) return '${diff.inSeconds}s';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  return '${diff.inDays}d';
}

/// Formats a DateTime into a human-readable "time since" string
/// Examples: "2 min ago", "1 hour ago", "3 days ago"
String formatTimeSince(DateTime? dateTime) {
  if (dateTime == null) {
    return '';
  }

  final now = DateTime.now();
  final localDateTime = dateTime.toLocal();
  final difference = now.difference(localDateTime);

  // TODO: [time_utils] l10n
  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return '$minutes min ago';
  } else if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours hour${hours == 1 ? '' : 's'} ago';
  } else if (difference.inDays < 7) {
    final days = difference.inDays;
    return '$days day${days == 1 ? '' : 's'} ago';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks week${weeks == 1 ? '' : 's'} ago';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$months month${months == 1 ? '' : 's'} ago';
  } else {
    final years = (difference.inDays / 365).floor();
    return '$years year${years == 1 ? '' : 's'} ago';
  }
}

/// Format a DateTime into a styled string for display in the UI
///
/// Examples: "Today 15:45", "Tomorrow 09:00", "Mar 5, 2024 14:30"
///
/// Also day names back to one week, e.g. "Monday 15:45"
String formatDateTimeForDisplay(DateTime? dateTime) {
  if (dateTime == null) return '—';

  final localDateTime = dateTime.toLocal();

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(
    localDateTime.year,
    localDateTime.month,
    localDateTime.day,
  );
  final timeString =
      '${localDateTime.hour}:${localDateTime.minute.toString().padLeft(2, '0')}';

  if (date == today) {
    return 'Today $timeString';
  } else if (date == today.add(const Duration(days: 1))) {
    return 'Tomorrow $timeString';
  } else if (date == today.subtract(const Duration(days: 1))) {
    return 'Yesterday $timeString';
  } else if (date.isAfter(today.subtract(const Duration(days: 7)))) {
    return '${_formatDayOfWeek(date)} $timeString';
  } else {
    return '${_formatMonth(date)} $timeString';
  }
}

String _formatDayOfWeek(DateTime date) {
  const weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return weekdayNames[date.weekday - 1];
}

// TODO: [time_utils] l10n
String _formatMonth(DateTime date) {
  const monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
}
