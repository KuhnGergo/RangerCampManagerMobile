class UserJoinedGroupData {
  final String userId;
  final String userName;
  final String groupId;

  UserJoinedGroupData({
    required this.userId,
    required this.userName,
    required this.groupId,
  });

  factory UserJoinedGroupData.fromJson(Map<String, dynamic> json) {
    return UserJoinedGroupData(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      groupId: json['groupId'] as String,
    );
  }
}

class UserLeftGroupData {
  final String userId;
  final String userName;
  final String groupId;

  UserLeftGroupData({
    required this.userId,
    required this.userName,
    required this.groupId,
  });

  factory UserLeftGroupData.fromJson(Map<String, dynamic> json) {
    return UserLeftGroupData(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      groupId: json['groupId'] as String,
    );
  }
}

class GroupEndedData {
  final String groupId;
  final GroupEndedBy endedBy;
  final DateTime timestamp;

  GroupEndedData({
    required this.groupId,
    required this.endedBy,
    required this.timestamp,
  });

  factory GroupEndedData.fromJson(Map<String, dynamic> json) {
    return GroupEndedData(
      groupId: json['groupId'] as String,
      endedBy: GroupEndedBy.fromJson(json['endedBy'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class GroupEndedBy {
  final String userId;
  final String userName;

  GroupEndedBy({required this.userId, required this.userName});

  factory GroupEndedBy.fromJson(Map<String, dynamic> json) {
    return GroupEndedBy(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
    );
  }
}
