import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mastercs_mobile/presentation/components/error/error_snackbar.dart';

void showUpdateDueDateDialog({
  required BuildContext context,
  DateTime? initialValue,
  required Future<void> Function(DateTime) confirmAction,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _UpdateDueDateDialog(
      initialValue: initialValue,
      confirmAction: confirmAction,
    ),
  );
}

class _UpdateDueDateDialog extends StatefulWidget {
  final DateTime? initialValue;
  final Future<void> Function(DateTime) confirmAction;

  const _UpdateDueDateDialog({this.initialValue, required this.confirmAction});

  @override
  State<_UpdateDueDateDialog> createState() => _UpdateDueDateDialogState();
}

class _UpdateDueDateDialogState extends State<_UpdateDueDateDialog> {
  DateTime? _selectedDate;
  bool _isUpdating = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialValue;
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _errorText = null;
      });
    }
  }

  Future<void> _onConfirm() async {
    if (_selectedDate == null) {
      setState(() => _errorText = 'Please select a due date');
      return;
    }
    setState(() => _isUpdating = true);
    try {
      await widget.confirmAction(_selectedDate!);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Update Due Date'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _isUpdating ? null : _selectDate,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Due Date',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _errorText,
                enabled: !_isUpdating,
              ),
              child: Text(
                _selectedDate != null
                    ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                    : 'Select a date',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _selectedDate != null
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isUpdating ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isUpdating ? null : _onConfirm,
          child: _isUpdating
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}
