import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/select_chat_screen.dart';
import 'package:mastercs_mobile/presentation/components/widgets/account_avatar.dart';
import 'package:mastercs_mobile/presentation/components/member_search/member_search_screen.dart';

import 'package:mastercs_mobile/presentation/navigation/navbar.dart';
import 'package:mastercs_mobile/presentation/navigation/navigation_provider.dart';
import 'package:mastercs_mobile/background_service/location_tracking_service.dart';
import 'package:mastercs_mobile/providers/data/camp_role_provider.dart';
import 'package:mastercs_mobile/providers/data/camp_provider.dart';

import 'package:mastercs_mobile/presentation/app/map/map_screen.dart';
import 'package:mastercs_mobile/presentation/app/camp/camp_screen.dart';
import 'package:mastercs_mobile/presentation/app/payments/payments_screen.dart';

/// Main app entry point - handles camp selection flow
class AppScreen extends ConsumerStatefulWidget {
  final VoidCallback onDeselectCamp;

  const AppScreen({super.key, required this.onDeselectCamp});

  @override
  ConsumerState<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends ConsumerState<AppScreen> {
  late PageController _pageController;
  late final LocationTrackingService _locationTrackingService;

  @override
  void initState() {
    super.initState();
    _locationTrackingService = ref.read(
      locationTrackingServiceProvider.notifier,
    );
    _pageController = PageController(
      initialPage: ref.read(navigationIndexProvider),
    );
    // Keep tracking state synced with auth/camp conditions.
    Future.microtask(() {
      _locationTrackingService.start();
    });
  }

  @override
  void dispose() {
    _locationTrackingService.stop();
    _pageController.dispose();
    super.dispose();
  }

  void _onNavBarTap(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navigationIndexProvider);
    final selectedIndexState = ref.read(navigationIndexProvider.notifier);
    final roleAsync = ref.watch(campRoleProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final currentPage = ref.watch(currentNavigationPageProvider);

    // Keep location tracking alive
    ref.watch(locationTrackingServiceProvider);

    // Build screen list based on role
    final screens = [
      const MapScreen(),
      const SelectChatScreen(),
      CampScreen(onDeselectCamp: widget.onDeselectCamp),
      if (roleAsync.maybeWhen(
        data: (role) => role != 'Staff',
        orElse: () => false,
      ))
        const PaymentsScreen(),
    ];

    // If the available tabs change (e.g. payments appears/disappears after camp
    // switch), the stored index can become out-of-range. Clamp it AFTER build
    // to avoid Riverpod's "modified during build" assertion.
    if (selectedIndex >= screens.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        selectedIndexState.setIndex(screens.length - 1);
      });
    }

    // Sync page controller with navigation index when changed externally (e.g., from nav bar)
    if (_pageController.hasClients &&
        _pageController.page?.round() != selectedIndex) {
      _pageController.jumpToPage(selectedIndex);
    }

    // Get dynamic title for Camp screen
    final displayTitle = currentPage.index == 2
        ? ref
              .watch(campProvider)
              .maybeWhen(
                data: (camp) => camp?.name ?? currentPage.title,
                orElse: () => currentPage.title,
              )
        : currentPage.title;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        forceMaterialTransparency: true,
        centerTitle: true,
        title: Text(
          displayTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(9),
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: const AccountAvatar(),
        ),
        actions: [
          if (currentPage.index != 0)
            Hero(
              tag: memberSearchHeroTag,
              child: Material(
                type: MaterialType.transparency,
                child: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MemberSearchScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (selectedPage) {
          selectedIndexState.setIndex(selectedPage);
        },
        children: screens,
      ),
      bottomNavigationBar: BottomNavBar(onTap: _onNavBarTap),
    );
  }
}
