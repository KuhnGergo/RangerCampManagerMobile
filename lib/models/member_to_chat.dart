class MemberToChatData {
  final String userId;
  final String chatId;
  final DateTime? lastViewed;

  MemberToChatData({
    required this.userId,
    required this.chatId,
    this.lastViewed,
  });

  MemberToChatData copyWith({
    String? userId,
    String? chatId,
    DateTime? lastViewed,
  }) {
    return MemberToChatData(
      userId: userId ?? this.userId,
      chatId: chatId ?? this.chatId,
      lastViewed: lastViewed ?? this.lastViewed,
    );
  }
}
