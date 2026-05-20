import 'package:mastercs_mobile/models/socket/location_models.dart';

class AuthenticatedData {
  final String userId;
  final List<OnlineUsersByCamp> onlineUsers;
  final List<LocationsByCamp> locations;

  AuthenticatedData({
    required this.userId,
    required this.onlineUsers,
    required this.locations,
  });

  factory AuthenticatedData.fromJson(Map<String, dynamic> json) {
    return AuthenticatedData(
      userId: json['userId'] as String,
      onlineUsers: (json['onlineUsers'] as List)
          .map((e) => OnlineUsersByCamp.fromJson(e as Map<String, dynamic>))
          .toList(),
      locations: (json['locations'] as List)
          .map((e) => LocationsByCamp.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OnlineUsersByCamp {
  final String campId;
  final List<UserOnlineStatus> users;

  OnlineUsersByCamp({required this.campId, required this.users});

  factory OnlineUsersByCamp.fromJson(Map<String, dynamic> json) {
    return OnlineUsersByCamp(
      campId: json['campId'] as String,
      users: (json['users'] as List)
          .map((e) => UserOnlineStatus.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class UserOnlineStatus {
  final String userId;
  final bool isOnline;
  final DateTime? lastSeenAt;

  UserOnlineStatus({
    required this.userId,
    required this.isOnline,
    this.lastSeenAt,
  });

  factory UserOnlineStatus.fromJson(Map<String, dynamic> json) {
    return UserOnlineStatus(
      userId: json['userId'] as String,
      isOnline: json['isOnline'] as bool,
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.parse(json['lastSeenAt'] as String)
          : null,
    );
  }
}

class LocationsByCamp {
  final String campId;
  final List<LocationUpdatedData> users;

  LocationsByCamp({required this.campId, required this.users});

  factory LocationsByCamp.fromJson(Map<String, dynamic> json) {
    final campId = json['campId'] as String;

    return LocationsByCamp(
      campId: campId,
      users: (json['users'] as List)
          .map(
            (e) => LocationUpdatedData.fromJson(
              e as Map<String, dynamic>,
              campId: campId,
            ),
          )
          .toList(),
    );
  }
}

class UserConnectionUpdate {
  final String userId;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final DateTime updatedAt;

  UserConnectionUpdate({
    required this.userId,
    required this.isOnline,
    this.lastSeenAt,
    required this.updatedAt,
  });

  factory UserConnectionUpdate.fromJson(Map<String, dynamic> json) {
    return UserConnectionUpdate(
      userId: json['userId'] as String,
      isOnline: json['isOnline'] as bool,
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.parse(json['lastSeenAt'] as String)
          : null,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
