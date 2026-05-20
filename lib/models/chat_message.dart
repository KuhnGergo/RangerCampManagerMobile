import 'dart:convert';
import 'package:mastercs_mobile/core/schema/app_database.dart' as db;
import 'package:mastercs_mobile/core/schema/tables/messages_table.dart';

/// Typed message model that wraps the Drift Message entity
/// and provides structured access to the body JSON fields
class ChatMessage {
  final String id;
  final String? remoteId;
  final String chatRemoteId;
  final String userRemoteId;
  final DateTime? createdAt;
  final bool isSynced;
  final MessageStatus messageStatus;

  // Parsed body fields
  final String text;
  final String type;
  final String? replyToMessageId;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    this.remoteId,
    required this.chatRemoteId,
    required this.userRemoteId,
    this.createdAt,
    required this.isSynced,
    required this.messageStatus,
    required this.text,
    this.type = 'text',
    this.replyToMessageId,
    this.metadata,
  });

  /// Create from Drift Message entity
  factory ChatMessage.fromDriftMessage(db.Message message) {
    final bodyJson = jsonDecode(message.bodyJson) as Map<String, dynamic>;

    return ChatMessage(
      id: message.id,
      remoteId: message.remoteId,
      chatRemoteId: message.chatRemoteId,
      userRemoteId: message.userRemoteId,
      createdAt: message.createdAt,
      isSynced: message.isSynced,
      messageStatus: message.messageStatus,
      text: bodyJson['text'] as String? ?? '',
      type: bodyJson['type'] as String? ?? 'text',
      replyToMessageId: bodyJson['replyToMessageId'] as String?,
      metadata: bodyJson['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to body JSON for storage
  Map<String, dynamic> toBodyJson() {
    return {
      'text': text,
      'type': type,
      if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  ChatMessage copyWith({
    String? id,
    String? remoteId,
    String? chatRemoteId,
    String? userRemoteId,
    DateTime? createdAt,
    bool? isSynced,
    MessageStatus? messageStatus,
    String? text,
    String? type,
    String? replyToMessageId,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      chatRemoteId: chatRemoteId ?? this.chatRemoteId,
      userRemoteId: userRemoteId ?? this.userRemoteId,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      messageStatus: messageStatus ?? this.messageStatus,
      text: text ?? this.text,
      type: type ?? this.type,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      metadata: metadata ?? this.metadata,
    );
  }
}
