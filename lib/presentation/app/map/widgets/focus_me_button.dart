import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/app/map/map_controller.dart';
import 'package:mastercs_mobile/presentation/components/widgets/account_circle.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';

class FocusButton extends ConsumerWidget {
  const FocusButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = ref.read(mapControllerProvider.notifier);
    final mapState = ref.watch(mapControllerProvider);
    final myUserId = ref.watch(authProvider.notifier).getUserId;
    final followedMember = mapState.followedMember;

    final hasFollowedMember = followedMember != null;
    final isDefaultSelf =
        hasFollowedMember &&
        myUserId != null &&
        followedMember.userRemoteId == myUserId;

    final IconData icon;
    final Color overlayColor;
    final Color iconColor;
    final VoidCallback onTap;

    if (isDefaultSelf) {
      icon = Icons.gps_fixed;
      overlayColor = colorScheme.primaryContainer;
      iconColor = colorScheme.onPrimaryContainer;
      onTap = controller.followMyUser;
    } else if (hasFollowedMember) {
      if (mapState.isFollowMode) {
        icon = Icons.person_remove_alt_1;
        overlayColor = colorScheme.tertiaryContainer;
        iconColor = colorScheme.onTertiaryContainer;
        onTap = controller.clearFollowedMember;
      } else {
        icon = Icons.gps_fixed;
        overlayColor = colorScheme.primaryContainer;
        iconColor = colorScheme.onPrimaryContainer;
        onTap = () => controller.setFollowMode(true);
      }
    } else {
      icon = Icons.my_location;
      overlayColor = colorScheme.primaryContainer;
      iconColor = colorScheme.onSurface;
      onTap = controller.followMyUser;
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        shape: BoxShape.circle,
      ),
      child: Material(
        color: colorScheme.surface,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 48,
            height: 48,
            child: hasFollowedMember
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: AccountCircle(
                          name: followedMember.name,
                          userId: followedMember.userRemoteId,
                          fileName: followedMember.profilePicture,
                          radius: 22,
                          backgroundColor: colorScheme.surfaceContainer,
                          textColor: colorScheme.onSurface,
                          showOnlineIndicator: false,
                          role: followedMember.role,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: overlayColor.withAlpha(145),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(icon, color: iconColor, size: 18),
                      ),
                    ],
                  )
                : Center(child: Icon(icon, color: iconColor, size: 20)),
          ),
        ),
      ),
    );
  }
}
