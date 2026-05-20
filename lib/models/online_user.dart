class OnlineUser {
  final String userId;
  final bool isOnline;
  final DateTime? lastSeenAt;

  OnlineUser({required this.userId, required this.isOnline, this.lastSeenAt});

  OnlineUser copyWith({String? userId, bool? isOnline, DateTime? lastSeenAt}) {
    return OnlineUser(
      userId: userId ?? this.userId,
      isOnline: isOnline ?? this.isOnline,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }
}
