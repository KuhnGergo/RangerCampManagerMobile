class ChatMember {
  // From Member (member_to_camp)
  final String userRemoteId;
  final String name;
  final String? profilePicturePath;
  final String role;
  final String? groupId;
  final String? roomId;

  // From MemberToChat
  final String chatRemoteId;
  final DateTime? lastViewed;

  ChatMember({
    required this.userRemoteId,
    required this.name,
    this.profilePicturePath,
    required this.role,
    this.groupId,
    this.roomId,
    required this.chatRemoteId,
    this.lastViewed,
  });

  ChatMember copyWith({
    String? userRemoteId,
    String? name,
    String? profilePicturePath,
    String? role,
    String? groupId,
    String? roomId,
    String? chatRemoteId,
    DateTime? lastViewed,
  }) {
    return ChatMember(
      userRemoteId: userRemoteId ?? this.userRemoteId,
      name: name ?? this.name,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      role: role ?? this.role,
      groupId: groupId ?? this.groupId,
      roomId: roomId ?? this.roomId,
      chatRemoteId: chatRemoteId ?? this.chatRemoteId,
      lastViewed: lastViewed ?? this.lastViewed,
    );
  }
}
