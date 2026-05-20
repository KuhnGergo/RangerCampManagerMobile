class PermissionDeniedException implements Exception {
  final String message;

  const PermissionDeniedException(this.message);

  @override
  String toString() => message;
}
