import 'package:latlong2/latlong.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';

class Member {
  String userRemoteId;
  String name;
  String? profilePicture;
  String role;
  String? groupId;
  String? roomId;
  bool isOnline;
  DateTime? lastSeenAt;
  Location? lastLocation;
  double? distanceInMeters;

  Member({
    required this.userRemoteId,
    required this.name,
    this.profilePicture,
    required this.role,
    this.groupId,
    this.roomId,
    this.isOnline = false,
    this.lastSeenAt,
    this.lastLocation,
    this.distanceInMeters,
  });

  LatLng? get position => lastLocation != null
      ? LatLng(lastLocation!.latitude, lastLocation!.longitude)
      : null;

  String? get distanceText {
    if (distanceInMeters == null) return null;
    if (distanceInMeters! < 1000) {
      return '${distanceInMeters!.toStringAsFixed(0)}m';
    }
    if (distanceInMeters! < 100000) {
      return '${(distanceInMeters! / 1000).toStringAsFixed(1)}km';
    }
    return '${(distanceInMeters! / 1000).toStringAsFixed(0)}km';
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      userRemoteId: map['id'],
      name: map['name'],
      profilePicture: map['profilePicture'],
      role: map['role'],
      groupId: map['groupId'],
      roomId: map['roomId'],
      isOnline: map['isOnline'] ?? false,
      lastSeenAt: map['lastSeenAt'] != null
          ? DateTime.parse(map['lastSeenAt'])
          : null,
      lastLocation: map['lastLocation'] != null
          ? Location(
              userRemoteId: map['id'],
              campRemoteId: map['groupId'] ?? '',
              latitude: map['lastLocation']['latitude']?.toDouble() ?? 0.0,
              longitude: map['lastLocation']['longitude']?.toDouble() ?? 0.0,
              lastUpdated: map['lastLocation']['timestamp'] != null
                  ? DateTime.parse(map['lastLocation']['timestamp'])
                  : DateTime.now(),
            )
          : null,
      distanceInMeters: map['distanceInMeters']?.toDouble(),
    );
  }

  factory Member.error() {
    return Member(
      userRemoteId: 'error',
      name: 'Unknown',
      role: 'Unknown',
      isOnline: false,
      lastLocation: null,
      distanceInMeters: null,
    );
  }

  Member copyWith({
    String? userRemoteId,
    String? name,
    String? profilePicture,
    String? role,
    String? groupId,
    String? roomId,
    bool? isOnline,
    DateTime? lastSeenAt,
    Location? lastLocation,
    double? distanceInMeters,
  }) {
    return Member(
      userRemoteId: userRemoteId ?? this.userRemoteId,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
      groupId: groupId ?? this.groupId,
      roomId: roomId ?? this.roomId,
      isOnline: isOnline ?? this.isOnline,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      lastLocation: lastLocation ?? this.lastLocation,
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
    );
  }
}
