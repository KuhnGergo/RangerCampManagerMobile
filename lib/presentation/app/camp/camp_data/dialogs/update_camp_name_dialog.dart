import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/app/camp/camp_data/dialogs/update_camp_name_controller.dart';

class UpdateCampNameDialog extends ConsumerStatefulWidget {
  final String currentName;

  const UpdateCampNameDialog({super.key, required this.currentName});

  @override
  ConsumerState<UpdateCampNameDialog> createState() =>
      _UpdateCampNameDialogState();
}

class _UpdateCampNameDialogState extends ConsumerState<UpdateCampNameDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(updateCampNameControllerProvider.notifier)
          .initialize(widget.currentName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = ref.read(updateCampNameControllerProvider.notifier);
    final state = ref.watch(updateCampNameControllerProvider);

    ref.listen(updateCampNameControllerProvider, (previous, next) {
      if (next.success && !previous!.success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camp name updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });

    return AlertDialog(
      title: const Text('Update Camp Name'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter a new name for your camp.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.nameController,
            onChanged: controller.updateName,
            decoration: InputDecoration(
              labelText: 'Camp Name',
              hintText: 'Enter camp name',
              prefixIcon: const Icon(Icons.cottage),
              errorText: state.error,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            enabled: !state.isUpdating,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: state.isUpdating
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: state.isUpdating ? null : controller.updateCampName,
          child: state.isUpdating
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
