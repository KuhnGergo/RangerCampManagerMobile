class LocationUpdatedData {
  final String userId;
  final String campId;
  final double latitude;
  final double longitude;
  final DateTime lastUpdated;

  LocationUpdatedData({
    required this.userId,
    required this.campId,
    required this.latitude,
    required this.longitude,
    required this.lastUpdated,
  });

  factory LocationUpdatedData.fromJson(
    Map<String, dynamic> json, {
    String? campId,
  }) {
    return LocationUpdatedData(
      userId: json['userId'] as String,
      campId: campId ?? json['campId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}
