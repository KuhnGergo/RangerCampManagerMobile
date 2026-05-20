import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncPolicy {
  final bool allowMobile;
  final bool allowWifi;

  const SyncPolicy({required this.allowMobile, required this.allowWifi});
}

final syncPolicyProvider = NotifierProvider<SyncPolicyNotifier, SyncPolicy>(
  SyncPolicyNotifier.new,
);

class SyncPolicyNotifier extends Notifier<SyncPolicy> {
  @override
  SyncPolicy build() {
    return const SyncPolicy(allowMobile: false, allowWifi: true);
  }

  void toggleMobile(bool value) {
    state = SyncPolicy(allowMobile: value, allowWifi: state.allowWifi);
  }

  void toggleWifi(bool value) {
    state = SyncPolicy(allowMobile: state.allowMobile, allowWifi: value);
  }
}
