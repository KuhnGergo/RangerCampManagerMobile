import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/models/roles.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';
import 'package:mastercs_mobile/presentation/settings/settings_screen.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/providers/data/camp_members_list_provider.dart';
import 'package:mastercs_mobile/providers/location/all_members_with_location_provider.dart';

import 'providers/user_profile_provider.dart';
import 'widgets/user_info_section.dart';
import 'widgets/location_section.dart';
import 'widgets/owner_member_actions.dart';
import 'widgets/payments_section.dart';
import 'widgets/pending_member_actions.dart';
import 'widgets/profile_header.dart';
import 'widgets/social_section.dart';

/// User profile screen with role-based visibility.
class UserProfileScreen extends ConsumerWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(allMembersWithLocationProvider);
    final allMembersAsync = ref.watch(campMembersListProvider);
    final userAsync = ref.watch(profileUserProvider(userId));
    final myRole = ref.watch(myRoleProvider);
    final myUserId = ref.read(authProvider.notifier).getUserId;

    return membersAsync.when(
      data: (members) {
        final user = userAsync.value;

        final member = members
            .where((m) => m.userRemoteId == userId)
            .firstOrNull;
        final fallbackMember = allMembersAsync.value
            ?.where((m) => m.userRemoteId == userId)
            .firstOrNull;

        final effectiveMember = member ?? fallbackMember;

        // Redirect to settings screen if viewing own profile
        if (myUserId == user?.remoteId || myUserId == userId) {
          return SettingsScreen();
        }

        if (user == null) {
          return const SizedBox();
        }

        if (effectiveMember == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop();
          });

          return const SizedBox();
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(forceMaterialTransparency: true),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  kToolbarHeight + 16,
                  16,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- Public info (everyone can see) ---
                    ProfileHeader(member: effectiveMember),
                    const SizedBox(height: 24),

                    ...[
                      UserInfoSection(user: user),
                      const SizedBox(height: 12),
                    ],

                    // --- Group / Room / Location (role-aware) ---
                    LocationSection(member: effectiveMember),
                    const SizedBox(height: 12),

                    // --- Social section (group + room summary) ---
                    SocialSection(member: effectiveMember),
                    const SizedBox(height: 12),

                    // --- Owner-only sections ---
                    if (myRole == Role.owner) ...[
                      // Payments management (only for campers)
                      if (Role.fromString(effectiveMember.role) == Role.camper)
                        PaymentsSection(userId: userId),
                      const SizedBox(height: 12),

                      // Pending member accept/decline
                      if (myRole == Role.owner &&
                          effectiveMember.role == Role.pending.toString()) ...[
                        PendingMemberActions(member: effectiveMember),
                        const SizedBox(height: 12),
                      ],

                      // Promote / Demote / Kick
                      if (myRole == Role.owner &&
                          effectiveMember.role != Role.pending.toString())
                        OwnerMemberActions(member: effectiveMember),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
              Container(
                height: kToolbarHeight + MediaQuery.of(context).padding.top,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.surface.withAlpha(160),
                      Theme.of(context).colorScheme.surface.withAlpha(100),
                      Theme.of(context).colorScheme.surface.withAlpha(40),
                      Theme.of(context).colorScheme.surface.withAlpha(0),
                    ],
                    stops: const [0.0, 0.3, 0.55, 0.75, 1.0],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('User Profile')),
        body: const Center(child: ThreeDotLoadingIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('User Profile')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}
