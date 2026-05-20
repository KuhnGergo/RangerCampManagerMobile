class PendingCampJoinRequestError implements Exception {
  final String? message;

  PendingCampJoinRequestError({this.message});

  @override
  String toString() => 'PendingCampJoinRequestError: $message';
}
