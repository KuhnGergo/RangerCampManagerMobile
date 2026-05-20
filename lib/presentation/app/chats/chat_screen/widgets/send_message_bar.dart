import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_screen/controllers/typing_controller_provider.dart';
import 'package:mastercs_mobile/presentation/app/chats/utils/chat_color_helper.dart';

class SendMessageBar extends ConsumerStatefulWidget {
  final String? chatId;
  final String? chatColor;
  final Function(String message)? onSend;
  final bool enabled;

  const SendMessageBar({
    super.key,
    this.chatId,
    this.chatColor,
    this.onSend,
    this.enabled = false,
  });

  @override
  ConsumerState<SendMessageBar> createState() => _SendMessageBarState();
}

class _SendMessageBarState extends ConsumerState<SendMessageBar> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_controller.text.trim().isEmpty) return;

    final message = _controller.text.trim();

    // Notify typing controller that message was sent
    if (widget.chatId != null) {
      ref.read(typingControllerProvider(widget.chatId!)).onMessageSent();
    }

    if (widget.onSend != null) {
      widget.onSend!(message);
    }
    _controller.clear();
    setState(() {
      _hasText = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasActiveSendState = widget.enabled && _hasText;
    final activeArrowColor = widget.chatColor != null
        ? ChatColorHelper.getFullColor(
            widget.chatColor,
            fallback: colorScheme.primary,
          )
        : colorScheme.primary;
    final activeArrowBackground = widget.chatColor != null
        ? ChatColorHelper.getBackgroundColor(
            widget.chatColor,
            fallback: colorScheme.primary,
          )
        : colorScheme.primaryContainer;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colorScheme.surface),
      child: SafeArea(
        child: Builder(
          builder: (context) {
            final maxInputHeight = MediaQuery.of(context).size.height * 0.4;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxInputHeight),
                    child: TextField(
                      controller: _controller,
                      enabled: widget.enabled,
                      minLines: 1,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: widget.enabled
                            ? 'Type a message...'
                            : 'Select a chat to send messages',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _hasText = value.trim().isNotEmpty;
                        });

                        // Notify typing controller of text changes
                        if (widget.chatId != null) {
                          ref
                              .read(typingControllerProvider(widget.chatId!))
                              .onTextChanged(value);
                        }
                      },
                      onSubmitted: widget.enabled ? (_) => _handleSend() : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: hasActiveSendState ? _handleSend : null,
                  icon: Icon(
                    Icons.arrow_upward,
                    color: hasActiveSendState
                        ? activeArrowColor
                        : colorScheme.onSurfaceVariant.withAlpha(128),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: hasActiveSendState
                        ? activeArrowBackground
                        : colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
