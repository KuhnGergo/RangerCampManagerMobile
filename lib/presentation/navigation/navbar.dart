import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:mastercs_mobile/presentation/navigation/navigation_provider.dart';
import 'package:mastercs_mobile/providers/data/camp_role_provider.dart';

class BottomNavBar extends ConsumerWidget {
  final void Function(int)? onTap;

  const BottomNavBar({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);
    final roleAsync = ref.watch(campRoleProvider);

    // Determine if payments tab should be visible
    final showPayments = roleAsync.maybeWhen(
      data: (role) => role != 'Staff',
      orElse: () => false,
    );

    final mapIcon = selectedIndex == 0
        ? Icons.location_on
        : Icons.location_on_outlined;
    final chatIcon = selectedIndex == 1
        ? Icons.chat_bubble
        : Icons.chat_bubble_outline;
    final campIcon = selectedIndex == 2
        ? Icons.terrain
        : Icons.terrain_outlined;
    final paymentsIcon = selectedIndex == 3
        ? Icons.payments
        : Icons.payments_outlined;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: GNav(
          selectedIndex: selectedIndex,

          onTabChange: (index) {
            if (onTap != null) {
              onTap!(index);
            } else {
              ref.read(navigationIndexProvider.notifier).setIndex(index);
            }
          },
          tabs: [
            GButton(icon: mapIcon, text: 'Map'),
            GButton(icon: chatIcon, text: 'Chats'),
            GButton(icon: campIcon, text: 'Camp'),
            if (showPayments) GButton(icon: paymentsIcon, text: 'Payments'),
          ],
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          gap: 8,
          activeColor: Theme.of(context).colorScheme.primary,
          rippleColor: Theme.of(context).colorScheme.primary.withAlpha(100),
          hoverColor: Theme.of(context).colorScheme.primary.withAlpha(50),
          iconSize: 24,
          tabBackgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withAlpha(20),
          color: Theme.of(context).colorScheme.onSurface,
          haptic: true,
        ),
      ),
    );
  }
}
