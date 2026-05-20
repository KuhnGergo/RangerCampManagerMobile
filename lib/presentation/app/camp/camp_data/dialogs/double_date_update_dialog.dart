import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mastercs_mobile/presentation/components/error/error_snackbar.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';

void showDoubleDateUpdateDialog(
  BuildContext context, {
  required DateTime initialStartDate,
  required DateTime initialEndDate,
  required Future<void> Function(DateTime startDate, DateTime endDate)
  confirmAction,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DoubleDateUpdateDialog(
      initialStartDate: initialStartDate,
      initialEndDate: initialEndDate,
      confirmAction: confirmAction,
    ),
  );
}

class _DoubleDateUpdateDialog extends StatefulWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final Future<void> Function(DateTime startDate, DateTime endDate)
  confirmAction;

  const _DoubleDateUpdateDialog({
    required this.initialStartDate,
    required this.initialEndDate,
    required this.confirmAction,
  });

  @override
  State<_DoubleDateUpdateDialog> createState() =>
      _DoubleDateUpdateDialogState();
}

class _DoubleDateUpdateDialogState extends State<_DoubleDateUpdateDialog> {
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isUpdating = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  void _updateStartDate(DateTime date) {
    setState(() {
      _startDate = date;
      _errorText = null;
      // Ensure end date is after start date
      if (_endDate.isBefore(date)) {
        _endDate = date.add(const Duration(days: 1));
      }
    });
  }

  void _updateEndDate(DateTime date) {
    setState(() {
      _endDate = date;
      _errorText = null;
    });
  }

  String? _validateDates() {
    if (_endDate.isBefore(_startDate)) {
      return 'End date must be after start date';
    }
    if (_endDate.isAtSameMomentAs(_startDate)) {
      return 'End date must be after start date';
    }
    return null;
  }

  Future<void> _onConfirm() async {
    final validationError = _validateDates();
    if (validationError != null) {
      setState(() => _errorText = validationError);
      return;
    }

    setState(() => _isUpdating = true);
    try {
      await widget.confirmAction(_startDate, _endDate);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        showError(
          context,
          'Failed to update camp dates',
          extendedText: e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text(
        'Change Camp Dates',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Update the start and end dates for your camp.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorText!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          _buildDateField(
            context,
            label: 'Start Date',
            date: _startDate,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              );
              if (picked != null) _updateStartDate(picked);
            },
            enabled: !_isUpdating,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: _buildDateField(
              context,
              label: 'End Date',
              date: _endDate,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: _startDate.add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (picked != null) _updateEndDate(picked);
              },
              enabled: !_isUpdating,
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isUpdating ? null : _onConfirm,
          child: _isUpdating
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: ThreeDotLoadingIndicator(
                    dotSize: 2.5,
                    orbitRadius: 7,
                    spinDuration: const Duration(seconds: 1),
                    color: colorScheme.onPrimary,
                  ),
                )
              : const Text('Update'),
        ),
      ],
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: enabled ? onTap : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabled: enabled,
        ),
        child: Text(
          DateFormat('MMM dd, yyyy').format(date),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: enabled
                ? colorScheme.onSurface
                : colorScheme.onSurface.withAlpha(97),
          ),
        ),
      ),
    );
  }
}
