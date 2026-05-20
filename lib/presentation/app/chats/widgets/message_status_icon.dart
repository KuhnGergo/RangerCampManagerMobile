import 'package:flutter/material.dart';
import 'package:mastercs_mobile/core/schema/tables/messages_table.dart';

class MessageStatusIcon extends StatelessWidget {
  final MessageStatus? messageStatus;

  const MessageStatusIcon({super.key, this.messageStatus});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (messageStatus!) {
      case MessageStatus.sending:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              colorScheme.onPrimaryContainer.withAlpha(179),
            ),
          ),
        );
      case MessageStatus.sent:
        return Icon(
          Icons.check,
          size: 16,
          color: colorScheme.onPrimaryContainer.withAlpha(179),
        );
      case MessageStatus.arrived:
        return Icon(
          Icons.done_all,
          size: 16,
          color: colorScheme.onPrimaryContainer.withAlpha(179),
        );
      case MessageStatus.error:
        return Icon(Icons.error_outline, size: 16, color: Colors.red.shade300);
    }
  }
}
