import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/models/roles.dart';
import 'package:mastercs_mobile/presentation/components/widgets/account_circle.dart';
import 'package:mastercs_mobile/presentation/components/user_profile/user_profile_screen.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/providers/data/chats_list_provider.dart';
import 'package:mastercs_mobile/utils/time_utils.dart';

class MemberInfoItem extends ConsumerStatefulWidget {
  final Member member;
  final bool showRole;
  final bool showGroup;
  final bool showRoom;
  final bool showDistance;
  final bool locationFocus;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const MemberInfoItem({
    super.key,
    required this.member,
    this.showRole = true,
    this.showGroup = false,
    this.showRoom = false,
    this.showDistance = false,
    this.locationFocus = false,
    this.backgroundColor,
    this.onTap,
  });

  @override
  ConsumerState<MemberInfoItem> createState() => _MemberInfoItemState();
}

class _MemberInfoItemState extends ConsumerState<MemberInfoItem> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update every minute for time-ago text
    if (widget.locationFocus &&
        widget.member.lastLocation != null &&
        widget.member.lastLocation!.lastUpdated != null) {
      _timer = Timer.periodic(Duration(minutes: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bgColor = widget.backgroundColor ?? colorScheme.surfaceContainer;

    // Get chats to find group/room name and color
    final chatsAsync = ref.watch(chatsListProvider);
    final chats = chatsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => <Chat>[],
    );

    // Find group chat
    final groupChat = widget.member.groupId != null
        ? chats.firstWhere(
            (chat) =>
                chat.type == 'Group' && chat.typeId == widget.member.groupId,
            orElse: () =>
                Chat(remoteId: '', name: 'Group', campRemoteId: '', type: ''),
          )
        : null;

    // Find room chat
    final roomChat = widget.member.roomId != null
        ? chats.firstWhere(
            (chat) =>
                chat.type == 'Room' && chat.typeId == widget.member.roomId,
            orElse: () =>
                Chat(remoteId: '', name: 'Room', campRemoteId: '', type: ''),
          )
        : null;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap:
            widget.onTap ??
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      UserProfileScreen(userId: widget.member.userRemoteId),
                ),
              );
            },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              AccountCircle(
                name: widget.member.name,
                userId: widget.member.userRemoteId,
                fileName: widget.member.profilePicture,
                radius: 20,
                role:
                    widget.member.role == 'Owner' ||
                        widget.member.role == 'Staff'
                    ? widget.member.role
                    : null,
                isOnline: widget.member.isOnline,
                showOnlineIndicator: true,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.member.name,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (widget.showRole)
                            Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: _buildChip(
                                context,
                                icon: Role.fromString(widget.member.role).icon,
                                label: widget.member.role,
                              ),
                            ),
                          if (widget.showGroup &&
                              widget.member.role == 'Camper')
                            Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: _buildChip(
                                context,
                                icon: Icons.group,
                                label: widget.member.groupId != null
                                    ? (groupChat?.name ?? 'Group')
                                    : 'No Group',
                                isNull: widget.member.groupId == null,
                                chipColor: groupChat?.color != null
                                    ? Color(
                                        int.parse(
                                          groupChat!.color!.replaceFirst(
                                            '#',
                                            '0xFF',
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          if (widget.showRoom && widget.member.role == 'Camper')
                            Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: _buildChip(
                                context,
                                icon: Icons.meeting_room,
                                label: widget.member.roomId != null
                                    ? (roomChat?.name ?? 'Room')
                                    : 'No Room',
                                isNull: widget.member.roomId == null,
                                chipColor: roomChat?.color != null
                                    ? Color(
                                        int.parse(
                                          roomChat!.color!.replaceFirst(
                                            '#',
                                            '0xFF',
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          if (widget.showDistance &&
                              !widget.locationFocus &&
                              widget.member.role != 'Pending')
                            widget.member.distanceInMeters != null
                                ? Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: _buildChip(
                                      context,
                                      icon: Icons.location_on,
                                      label:
                                          '${(widget.member.distanceInMeters! / 1000).toStringAsFixed(1)} km',
                                    ),
                                  )
                                : Icon(
                                    Icons.location_disabled,
                                    size: 14,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.locationFocus && widget.member.role != 'Pending') ...[
                SizedBox(width: 8),
                _buildLocationFocusWidget(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isNull = false,
    Color? chipColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: isNull
              ? colorScheme.onSurfaceVariant.withAlpha(128)
              : colorScheme.onSurfaceVariant,
        ),

        SizedBox(width: 4),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: isNull
                ? colorScheme.onSurfaceVariant.withAlpha(128)
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );

    if (chipColor != null && !isNull) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: chipColor.withAlpha(100),
          borderRadius: BorderRadius.circular(12),
        ),
        child: content,
      );
    }

    return content;
  }

  Widget _buildLocationFocusWidget(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final myUserId = ref.watch(authProvider.notifier).getUserId;

    // No location data
    if (widget.member.lastLocation == null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          Icons.location_disabled,
          size: 24,
          color: colorScheme.onSurfaceVariant.withAlpha(128),
        ),
      );
    }

    // Has location data (distance may still be unavailable)
    final distanceInKm = widget.member.distanceInMeters != null
        ? widget.member.distanceInMeters! / 1000
        : null;
    final lastUpdated = widget.member.lastLocation?.lastUpdated;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.member.userRemoteId == myUserId) ...[
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.gps_fixed,
              size: 24,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ] else ...[
          // Distance container (bigger) - only when we can compute it
          if (distanceInKm != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${distanceInKm.toStringAsFixed(1)} km',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 4),
          // Time ago container (smaller)
          if (lastUpdated != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                formatTimeSince(lastUpdated),
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ],
    );
  }
}
