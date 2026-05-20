import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final selectedCampIdProvider =
    AsyncNotifierProvider<SelectedCampIdNotifier, String?>(() {
      return SelectedCampIdNotifier();
    });

class SelectedCampIdNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    return loadFromPrefs();
  }

  Future<void> deselect() async {
    await saveToPrefs(null);
    Future.microtask(() => state = const AsyncData(null));
  }

  Future<void> select(String campId) async {
    await saveToPrefs(campId);
    state = AsyncData(campId);
  }

  Future<void> saveToPrefs(String? campId) async {
    final prefs = await SharedPreferences.getInstance();
    if (campId == null) {
      await prefs.remove('selected_camp_id');
    } else {
      await prefs.setString('selected_camp_id', campId);
    }
  }

  Future<String?> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_camp_id');
  }
}
