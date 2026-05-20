class ChatViewedData {
  final String chatId;
  final String userId;
  final DateTime viewedAt;

  ChatViewedData({
    required this.chatId,
    required this.userId,
    required this.viewedAt,
  });

  factory ChatViewedData.fromJson(Map<String, dynamic> json) {
    return ChatViewedData(
      chatId: json['chatId'] as String,
      userId: json['userId'] as String,
      viewedAt: DateTime.parse(json['viewedAt'] as String),
    );
  }
}

class UserTypingData {
  final String chatId;
  final String userId;
  final String name;
  final bool isTyping;

  UserTypingData({
    required this.chatId,
    required this.userId,
    required this.name,
    required this.isTyping,
  });

  factory UserTypingData.fromJson(Map<String, dynamic> json) {
    return UserTypingData(
      chatId: json['chatId'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      isTyping: json['isTyping'] as bool,
    );
  }
}
