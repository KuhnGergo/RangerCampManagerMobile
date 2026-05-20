import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/app/chats/widgets/chat_color_selector_field.dart';
import 'package:mastercs_mobile/presentation/auth/utils/form_field_style.dart';
import 'package:mastercs_mobile/presentation/components/error/error_snackbar.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';
import 'package:mastercs_mobile/providers/actions/group_actions_provider.dart';
import 'package:mastercs_mobile/providers/actions/room_actions_provider.dart';
import 'package:mastercs_mobile/utils/chat_color_palette.dart';
import 'package:mastercs_mobile/utils/color_utils.dart';
import 'package:mastercs_mobile/utils/validators.dart';

Future<void> showCreateRoomAndGroupDialog({
  required BuildContext context,
  required bool isGroup,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _CreateRoomAndGroupDialog(isGroup: isGroup),
  );
}

class _CreateRoomAndGroupDialog extends ConsumerStatefulWidget {
  final bool isGroup;

  const _CreateRoomAndGroupDialog({required this.isGroup});

  @override
  ConsumerState<_CreateRoomAndGroupDialog> createState() =>
      _CreateRoomAndGroupDialogState();
}

class _CreateRoomAndGroupDialogState
    extends ConsumerState<_CreateRoomAndGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _joinCodeController;
  final int _nameMaxLength = 50;
  final int _joinCodeMaxLength = 12;

  Color _selectedColor = chatColorSeed;
  bool _isCreating = false;
  String? _nameError;
  String? _joinCodeError;

  String? _validateName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Please enter a ${widget.isGroup ? 'group' : 'room'} name';
    }
    if (trimmed.length > _nameMaxLength) {
      return 'Name must be $_nameMaxLength characters or less';
    }
    return null;
  }

  String? _validateJoinCode(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return Validators.joinCode(trimmed);
  }

  bool _validateForm() {
    final nameError = _validateName(_nameController.text);
    final joinCodeError = _validateJoinCode(_joinCodeController.text);

    if (!_formKey.currentState!.validate()) {
      return false;
    }

    setState(() {
      _nameError = nameError;
      _joinCodeError = joinCodeError;
    });

    return nameError == null && joinCodeError == null;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _joinCodeController = TextEditingController();
    _selectedColor = chatColorSeed;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (!_validateForm()) {
      return;
    }

    if (_isCreating) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final name = _nameController.text.trim();
      final joinCode = _joinCodeController.text.trim();
      final colorHex = ColorUtils.colorToHex(_selectedColor, includeHash: true);

      widget.isGroup
          ? await ref
                .read(groupActionsProvider.notifier)
                .create(
                  name: name,
                  color: colorHex,
                  joinCode: joinCode.isNotEmpty ? joinCode : null,
                )
          : await ref
                .read(roomActionsProvider.notifier)
                .create(
                  name: name,
                  color: colorHex,
                  joinCode: joinCode.isNotEmpty ? joinCode : null,
                );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showError(
          context,
          'Failed to create ${widget.isGroup ? 'group' : 'room'}.',
          extendedText: e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.isGroup ? Icons.groups : Icons.meeting_room,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Create ${widget.isGroup ? 'Group' : 'Room'}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _nameController,
                  maxLength: _nameMaxLength,
                  onChanged: (_) {
                    if (_nameError == null) return;
                    setState(() {
                      _nameError = null;
                    });
                  },
                  enabled: !_isCreating,
                  textCapitalization: TextCapitalization.words,
                  decoration: getFormFieldDecoration(
                    labelText: '${widget.isGroup ? 'Group' : 'Room'} Name',
                    hintText: widget.isGroup
                        ? 'e.g. Hiking Group'
                        : 'e.g. E113',
                    themeData: Theme.of(context),
                    errorText: _nameError,
                    enabled: !_isCreating,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Optionals',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: colorScheme.onSurface.withAlpha(200),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _joinCodeController,
                  maxLength: _joinCodeMaxLength,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  enableSuggestions: false,
                  onChanged: (_) {
                    if (_joinCodeError == null) return;
                    setState(() {
                      _joinCodeError = null;
                    });
                  },
                  enabled: !_isCreating,
                  decoration: getFormFieldDecoration(
                    labelText: 'Join Code',
                    themeData: Theme.of(context),
                    hintText: 'Leave empty for auto-generated',

                    prefixIcon: const Icon(Icons.vpn_key),
                    errorText: _joinCodeError,
                    enabled: !_isCreating,
                  ),
                ),
                const SizedBox(height: 8),

                ChatColorSelectorField(
                  labelText: '${widget.isGroup ? 'Group' : 'Room'} Color',
                  selectedColor: _selectedColor,
                  enabled: !_isCreating,
                  onChanged: (color) {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isCreating
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _isCreating ? null : _createGroup,
                      icon: _isCreating
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: ThreeDotLoadingIndicator(
                                color: colorScheme.onSurface,
                                dotSize: 2,
                                orbitRadius: 5,
                                spinDuration: const Duration(milliseconds: 800),
                              ),
                            )
                          : const Icon(Icons.add),
                      label: Text(_isCreating ? 'Creating...' : 'Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
