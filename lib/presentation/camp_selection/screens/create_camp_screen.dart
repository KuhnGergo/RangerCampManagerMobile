import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mastercs_mobile/presentation/auth/utils/form_field_style.dart';
import 'package:mastercs_mobile/presentation/camp_selection/controllers/create_camp_controller.dart';
import 'package:mastercs_mobile/presentation/components/error/error_snackbar.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';

class CreateCampScreen extends ConsumerStatefulWidget {
  const CreateCampScreen({super.key});

  @override
  ConsumerState<CreateCampScreen> createState() => _CreateCampScreenState();
}

class _CreateCampScreenState extends ConsumerState<CreateCampScreen> {
  late final TextEditingController nameController = TextEditingController();
  late final TextEditingController joinCodeController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    joinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final stateController = ref.read(createCampControllerProvider.notifier);
    final state = ref.watch(createCampControllerProvider);

    if (nameController.text != state.name) {
      nameController.value = TextEditingValue(
        text: state.name,
        selection: TextSelection.collapsed(offset: state.name.length),
      );
    }
    if (joinCodeController.text != state.joinCode) {
      joinCodeController.value = TextEditingValue(
        text: state.joinCode,
        selection: TextSelection.collapsed(offset: state.joinCode.length),
      );
    }

    ref.listen(createCampControllerProvider, (previous, next) {
      if (next.success && !previous!.success) {
        Navigator.of(context).pop();
        stateController.clearSuccess();
      }
      if (next.error != null && previous?.error == null) {
        showError(
          context,
          'Failed to create camp',
          extendedText: next.error.toString(),
        );
        stateController.clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Camp',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Camp Details',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              maxLength: CreateCampController.campNameMaxLength,
              onChanged: stateController.updateName,
              enabled: !state.isCreating,
              decoration: getFormFieldDecoration(
                themeData: Theme.of(context),
                labelText: 'Camp Name',
                hintText: 'Enter camp name',
                prefixIcon: const Icon(Icons.cottage),
                errorText: state.nameError,
                enabled: !state.isCreating,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    context,
                    label: 'Start Date',
                    date: state.startDate,
                    errorText: state.startDateError,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: state.startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        stateController.updateStartDate(picked);
                      }
                    },
                    enabled: !state.isCreating,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    context,
                    label: 'End Date',
                    date: state.endDate,
                    errorText: state.endDateError,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: state.endDate,
                        firstDate: state.startDate.add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        stateController.updateEndDate(picked);
                      }
                    },
                    enabled: !state.isCreating,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Text(
                    'Additional Options',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant.withAlpha(200),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Joincode and min group size information',
                    color: colorScheme.onSurfaceVariant.withAlpha(200),
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 28,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Optionals',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: 'Join code: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            ' If left blank a 12 character random code will be generated. Camp can be joined by entering the code or scanning QR code on join screen.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: 'Min group size: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            'This value is used to determine how many campers are needed to form a group.',

                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'In practice a group is deleted when less campers remained than the specified size.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),

                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: joinCodeController,
                    maxLength: CreateCampController.joinCodeMaxLength,
                    onChanged: stateController.updateJoinCode,
                    enabled: !state.isCreating,
                    decoration: getFormFieldDecoration(
                      themeData: Theme.of(context),
                      labelText: 'Join Code (Optional)',

                      hintText: 'Max 12 chars',
                      prefixIcon: const Icon(Icons.qr_code),
                      errorText: state.joinCodeError,
                      enabled: !state.isCreating,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IntrinsicWidth(
                  child: DropdownButtonFormField<int?>(
                    key: ValueKey(state.minGroupSize),
                    initialValue: state.minGroupSize,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    isExpanded: true,
                    decoration: getFormFieldDecoration(
                      themeData: Theme.of(context),
                      labelText: 'Min Size (Optional)',
                      hintText: 'Select',
                      prefixIcon: const Icon(Icons.groups_2_outlined),
                      errorText: state.minGroupSizeError,
                      enabled: !state.isCreating,
                    ),
                    items: <DropdownMenuItem<int?>>[
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('None'),
                      ),
                      ...List.generate(
                        CreateCampController.minGroupSizeMax + 1,
                        (index) => DropdownMenuItem<int?>(
                          value: index,
                          child: Text(index.toString()),
                        ),
                      ),
                    ],
                    onChanged: state.isCreating
                        ? null
                        : stateController.updateMinGroupSize,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: state.isCreating ? null : stateController.createCamp,
                icon: state.isCreating
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: ThreeDotLoadingIndicator(
                          color: colorScheme.onPrimary,
                          dotSize: 3,
                          spinDuration: const Duration(milliseconds: 800),
                          orbitRadius: 8,
                        ),
                      )
                    : const Icon(Icons.add_circle),
                label: Text(
                  state.isCreating ? 'Creating...' : 'Create Camp',
                  style: const TextStyle(fontSize: 16),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required DateTime date,
    String? errorText,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: enabled ? onTap : null,
      child: InputDecorator(
        decoration: getFormFieldDecoration(
          themeData: Theme.of(context),
          labelText: label,
          errorText: errorText,
          enabled: enabled,
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          DateFormat('MMM d, yyyy').format(date),
          style: TextStyle(
            color: enabled
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
