import 'package:flutter/material.dart';

class CampStatusResult {
  final String status; // 'ongoing', 'soon', 'finished', 'later'
  final String label; // Display text
  final Color color; // Status color
  final String distanceText; // e.g. "3 days until"

  CampStatusResult({
    required this.status,
    required this.label,
    required this.color,
    required this.distanceText,
  });
}

class CampStatusHelper {
  static int _daysUntilStart(DateTime startDate) {
    final now = DateTime.now();
    return startDate.difference(now).inDays;
  }

  static CampStatusResult getCampStatus({
    required DateTime? startDate,
    required DateTime? endDate,
    required ColorScheme colorScheme,
  }) {
    final now = DateTime.now();

    if (startDate == null || endDate == null) {
      return CampStatusResult(
        status: 'unknown',
        label: 'Unknown',
        color: colorScheme.surfaceContainerHighest,
        distanceText: 'N/A',
      );
    }

    if (now.isAfter(endDate)) {
      return CampStatusResult(
        status: 'finished',
        label: 'DONE',
        color: Colors.grey,
        distanceText: _getDistanceText(startDate, endDate, now),
      );
    } else if (now.isAfter(startDate) && now.isBefore(endDate)) {
      return CampStatusResult(
        status: 'ongoing',
        label: 'NOW',
        color: Colors.green,
        distanceText: _getDistanceText(startDate, endDate, now),
      );
    } else if (_daysUntilStart(startDate) <= 14) {
      return CampStatusResult(
        status: 'soon',
        label: 'SOON',
        color: Colors.orange,
        distanceText: _getDistanceText(startDate, endDate, now),
      );
    } else {
      return CampStatusResult(
        status: 'later',
        label: 'LATER',
        color: Colors.blue,
        distanceText: _getDistanceText(startDate, endDate, now),
      );
    }
  }

  static String _getDistanceText(
    DateTime startDate,
    DateTime endDate,
    DateTime now,
  ) {
    if (now.isAfter(endDate)) {
      // Camp has ended
      return 'ENDED';
    } else if (now.isAfter(startDate) && now.isBefore(endDate)) {
      // Camp is ongoing
      return _formatTimeRange(now, endDate);
    } else {
      // Camp is upcoming
      return _formatTimeRange(now, startDate);
    }
  }

  static String _formatTimeRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'N/A';
    }

    final duration = endDate.difference(startDate);
    final totalHours = duration.inHours;
    final isHungarian =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode
            .toLowerCase() ==
        'hu';

    // TODO: [camp_status_helper] l10n
    final startingLabel = isHungarian ? 'KEZDŐDIK' : 'STARTING';
    final yearsLabel = isHungarian ? 'ÉV' : 'YEARS';
    final daysLabel = isHungarian ? 'NAP' : 'DAYS';
    final hoursLabel = isHungarian ? 'ORA' : 'HOURS';

    if (totalHours <= 0) {
      return startingLabel;
    }

    final years = duration.inDays ~/ 365;
    final remainingAfterYearsDays = duration.inDays % 365;
    final remainingAfterYearsHours = totalHours % (365 * 24);
    final remainingHours = remainingAfterYearsHours % 24;

    if (years > 0) {
      return '$years $yearsLabel';
    }

    if (remainingAfterYearsDays > 0) {
      return '$remainingAfterYearsDays $daysLabel';
    }

    if (remainingHours > 0) {
      return '$remainingHours $hoursLabel';
    }

    return startingLabel;
  }
}
