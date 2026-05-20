class MessageReply {
  final String id;
  final String userId;
  final Map<String, dynamic> body;
  final DateTime createdAt;

  MessageReply({
    required this.id,
    required this.userId,
    required this.body,
    required this.createdAt,
  });

  factory MessageReply.fromJson(Map<String, dynamic> json) {
    return MessageReply(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      body: (json['body'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class NewMessage {
  final String id;
  final String chatId;
  final String userId;
  final Map<String, dynamic> body;
  final DateTime createdAt;
  final String? tempId;
  final MessageReply? replyToMessage;

  NewMessage({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.body,
    required this.createdAt,
    this.tempId,
    this.replyToMessage,
  });

  factory NewMessage.fromJson(Map<String, dynamic> json) {
    return NewMessage(
      id: json['id'] as String? ?? '',
      chatId: json['chatId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      body: (json['body'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      tempId: json['tempId'] as String?,
      replyToMessage: json['replyToMessage'] != null
          ? MessageReply.fromJson(
              json['replyToMessage'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class MessageHistoryData {
  final String chatId;
  final List<NewMessage> messages;
  final bool hasMore;
  final int offset;

  MessageHistoryData({
    required this.chatId,
    required this.messages,
    required this.hasMore,
    required this.offset,
  });

  factory MessageHistoryData.fromJson(Map<String, dynamic> json) {
    return MessageHistoryData(
      chatId: json['chatId'] as String? ?? '',
      messages:
          (json['messages'] as List?)
              ?.map((e) => NewMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hasMore: json['hasMore'] as bool? ?? false,
      offset: json['offset'] as int? ?? 0,
    );
  }
}
