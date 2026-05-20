import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/api/api.dart';
import 'package:mastercs_mobile/providers/actions/camp_actions_provider.dart';
import 'package:mastercs_mobile/repositories/camp_repository.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';

final chooseCampControllerProvider =
    AsyncNotifierProvider<ChooseCampController, void>(() {
      return ChooseCampController();
    });

class ChooseCampController extends AsyncNotifier<void> {
  late final repository = ref.read(campRepositoryProvider);

  @override
  void build() {
    return;
  }

  Future<void> selectCamp(String campId) async {
    state = AsyncValue.loading();

    try {
      await ref.read(campActionsProvider.notifier).selectCamp(campId);
      state = AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.day}/${date.month}/${date.year}';
  }

  void logout() {
    ref.read(authProvider.notifier).logout();
  }

  Future<void> refreshCamps() async {
    state = AsyncValue.loading();

    try {
      // await ref.read(campsListProvider.notifier).loadCamps();
      await ref.read(campActionsProvider.notifier).refreshCamps();
      state = AsyncValue.data(null);
    } catch (e, stackTrace) {
      if (e is ApiException) {
        state = AsyncValue.error(e, StackTrace.empty);
        return;
      }
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
