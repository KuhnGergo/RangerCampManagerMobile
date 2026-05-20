import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/models/chat_types.dart';
import 'package:mastercs_mobile/presentation/app/chats/widgets/chat_color_selector_field.dart';
import 'package:mastercs_mobile/presentation/components/error/error_snackbar.dart';
import 'package:mastercs_mobile/providers/actions/group_actions_provider.dart';
import 'package:mastercs_mobile/providers/actions/room_actions_provider.dart';
import 'package:mastercs_mobile/utils/chat_color_palette.dart';
import 'package:mastercs_mobile/utils/color_utils.dart';

Future<void> showUpdateColorDialog({
  required BuildContext context,
  BuildContext? errorContext,
  required Chat chat,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _UpdateChatColorDialog(chat: chat),
  );
}

class _UpdateChatColorDialog extends ConsumerStatefulWidget {
  final Chat chat;

  const _UpdateChatColorDialog({required this.chat});

  @override
  ConsumerState<_UpdateChatColorDialog> createState() =>
      _UpdateChatColorDialogState();
}

class _UpdateChatColorDialogState
    extends ConsumerState<_UpdateChatColorDialog> {
  late Color _selectedColor;
  bool _isUpdating = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _selectedColor = ColorUtils.parseColor(
      widget.chat.color,
      fallback: chatColorSeed,
    );
  }

  Future<void> _onConfirm() async {
    if (widget.chat.typeId == null) {
      setState(() => _errorText = 'Chat ID is missing');
      return;
    }

    setState(() {
      _isUpdating = true;
      _errorText = null;
    });

    try {
      final color = ColorUtils.colorToHex(_selectedColor, includeHash: true);
      final isGroup = widget.chat.type == ChatType.group.toString();
      final isRoom = widget.chat.type == ChatType.room.toString();

      if (isGroup) {
        await ref
            .read(groupActionsProvider.notifier)
            .updateGroup(groupId: widget.chat.typeId!, color: color);
      } else if (isRoom) {
        await ref
            .read(roomActionsProvider.notifier)
            .updateRoom(roomId: widget.chat.typeId!, color: color);
      } else {
        throw Exception('Only room and group chats can be recolored');
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        showError(
          context,
          'Failed to update color',
          extendedText: e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGroup = widget.chat.type == ChatType.group.toString();

    return AlertDialog(
      title: Text(
        'Change ${isGroup ? 'Group' : 'Room'} Color',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ChatColorSelectorField(
              labelText: 'Color',
              selectedColor: _selectedColor,
              errorText: _errorText,
              enabled: !_isUpdating,
              onChanged: (color) {
                setState(() {
                  _selectedColor = color;
                  _errorText = null;
                });
              },
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: _isUpdating
              ? null
              : () => Navigator.of(context).pop(false),
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
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}
