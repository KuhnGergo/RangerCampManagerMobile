import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mastercs_mobile/core/socket/socket_service.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});
