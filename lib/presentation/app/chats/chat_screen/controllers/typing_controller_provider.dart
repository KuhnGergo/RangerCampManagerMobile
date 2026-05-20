import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/socket/socket_provider.dart';

/// Provider for typing controller, family on chatId
/// Automatically handles socket communication
final typingControllerProvider = Provider.family<TypingController, String>((
  ref,
  chatId,
) {
  final controller = TypingController(chatId: chatId, ref: ref);

  ref.onDispose(() {
    controller.dispose();
  });

  return controller;
});

/// Typing controller that handles socket communication internally
class TypingController {
  final String chatId;
  final Ref ref;

  Timer? _debounceTimer;
  bool _isCurrentlyTyping = false;

  /// Minimum characters before triggering typing indicator
  final int minCharactersToTrigger;

  /// Duration of inactivity before sending typing=false
  final Duration inactivityTimeout;

  TypingController({
    required this.chatId,
    required this.ref,
    this.minCharactersToTrigger = 1,
    this.inactivityTimeout = const Duration(seconds: 3),
  });

  /// Call this method whenever the text field value changes
  void onTextChanged(String text) {
    final currentLength = text.length;

    // Cancel existing timer
    _debounceTimer?.cancel();

    // Check if we should start or continue typing
    if (currentLength >= minCharactersToTrigger) {
      // Send typing=true if not already typing
      if (!_isCurrentlyTyping) {
        _isCurrentlyTyping = true;
        _emitTyping(true);
        if (kDebugMode) {
          print('TypingController: Started typing in chat $chatId');
        }
      }

      // Reset the inactivity timer
      _debounceTimer = Timer(inactivityTimeout, _stopTyping);
    } else if (currentLength == 0 && _isCurrentlyTyping) {
      // Text is empty, immediately stop typing
      _stopTyping();
    }
  }

  /// Call this when the message is sent
  void onMessageSent() {
    _debounceTimer?.cancel();
    if (_isCurrentlyTyping) {
      _stopTyping();
    }
  }

  void _stopTyping() {
    if (_isCurrentlyTyping) {
      _isCurrentlyTyping = false;
      _emitTyping(false);
      if (kDebugMode) {
        print('TypingController: Stopped typing in chat $chatId');
      }
    }
    _debounceTimer?.cancel();
  }

  void _emitTyping(bool isTyping) {
    final socketService = ref.read(socketServiceProvider);
    socketService.setTyping(chatId: chatId, isTyping: isTyping);
  }

  void dispose() {
    _debounceTimer?.cancel();
    // Send final typing=false if still typing
    if (_isCurrentlyTyping) {
      _emitTyping(false);
    }
  }
}
