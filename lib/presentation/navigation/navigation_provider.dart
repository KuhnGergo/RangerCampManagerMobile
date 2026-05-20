import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/data/camp_role_provider.dart';

/// Represents a navigation page with its metadata
class NavigationPage {
  final int index;
  final String title;
  final String label;

  const NavigationPage({
    required this.index,
    required this.title,
    required this.label,
  });
}

/// Available navigation pages
class NavigationPages {
  static const map = NavigationPage(index: 0, title: 'Map', label: 'Map');

  static const chats = NavigationPage(index: 1, title: 'Chat', label: 'Chats');

  static const camp = NavigationPage(index: 2, title: 'Camp', label: 'Camp');

  static const payments = NavigationPage(
    index: 3,
    title: 'Payments',
    label: 'Payments',
  );

  /// Get all available pages based on role
  static List<NavigationPage> getPages({required bool showPayments}) {
    return [map, chats, camp, if (showPayments) payments];
  }

  /// Get page by index
  static NavigationPage getPageByIndex(
    int index, {
    required bool showPayments,
  }) {
    final pages = getPages(showPayments: showPayments);
    if (index >= 0 && index < pages.length) {
      return pages[index];
    }
    return camp; // Default fallback
  }
}

// Provider to manage the selected navigation index
class NavigationIndexNotifier extends Notifier<int> {
  @override
  int build() {
    return 2; // Default to camp tab while loading
  }

  /// Set the navigation index
  void setIndex(int index) {
    state = index;
  }
}

final navigationIndexProvider = NotifierProvider<NavigationIndexNotifier, int>(
  () => NavigationIndexNotifier(),
);

/// Provider for the current navigation page
final currentNavigationPageProvider = Provider<NavigationPage>((ref) {
  final index = ref.watch(navigationIndexProvider);
  final roleAsync = ref.watch(campRoleProvider);

  final showPayments = roleAsync.maybeWhen(
    data: (role) => role != 'Staff',
    orElse: () => false,
  );

  return NavigationPages.getPageByIndex(index, showPayments: showPayments);
});
