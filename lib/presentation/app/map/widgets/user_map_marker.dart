import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/models/roles.dart';
import 'package:mastercs_mobile/presentation/app/chats/utils/chat_color_helper.dart';
import 'package:mastercs_mobile/presentation/components/user_profile/providers/user_profile_provider.dart';
import 'package:mastercs_mobile/presentation/components/widgets/account_circle.dart';
import 'package:mastercs_mobile/utils/time_utils.dart';

/// A teardrop/pin-shaped map marker for a camp member.
///
/// Layout (top → bottom, anchored at the tail tip):
///   ┌──────────────────┐
///   │  Name  ·  2m ago │  ← dark label badge
///   └──────────────────┘
///         ╭────────╮
///         │  [👤🟢] │  ← colored circle with avatar + online dot
///         ╰───┬────╯
///              ▼       ← triangle tail (pin tip = map LatLng anchor)
///
/// The circle is filled with the member's group color when a groupId is set.
class UserMapMarker extends ConsumerWidget {
  final Member member;
  final bool self;
  final bool highlighted;

  // Used by flutter_map Marker width/height to avoid clipping marker label.
  static const double recommendedMarkerWidth = 200.0;
  static const double recommendedMarkerHeight = 110.0;

  static const double _circleSize = 36.0;
  static const double _tailWidth = 21.0;
  static const double _tailHeight = 8.0;

  const UserMapMarker({
    super.key,
    required this.member,
    this.self = false,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    // Resolve group color: look up the chat whose typeId == member.groupId
    final groupChat = member.groupId != null
        ? ref.watch(memberGroupChatProvider(member.groupId!))
        : null;

    final pinColor = groupChat?.color != null
        ? Color.alphaBlend(
            ChatColorHelper.getFullColor(groupChat!.color),
            colorScheme.surface,
          )
        : colorScheme.surfaceContainer;

    final roleIcon = Role.fromString(member.role).icon;

    final timeAgo = formatTimeAgoCompact(member.lastLocation?.lastUpdated);
    final displayName = self ? 'Me' : member.name;
    final markerScale = highlighted ? 1.1 : 1.0;

    return Transform.scale(
      scale: markerScale,
      child: FractionalTranslation(
        // Shift the whole marker up so the tail tip is at the LatLng anchor point. Column needs to extends upwards from the tail.
        translation: const Offset(0, -1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // ── Label (name + last-update time) ──────────────────────────────
            Container(
              constraints: const BoxConstraints(maxWidth: 188),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 4,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      softWrap: false,
                    ),
                    Icon(
                      roleIcon,
                      size: 12,
                      color: colorScheme.onSurface.withAlpha(180),
                    ),
                    if (timeAgo.isNotEmpty)
                      Text(
                        timeAgo,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          color: colorScheme.onSurface.withAlpha(180),
                          fontSize: 10,
                          height: 1.2,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 3),

            // ── Pin head: colored circle with avatar + online indicator ───────
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Colored background circle with white border and shadow
                Container(
                  width: _circleSize,
                  height: _circleSize,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: pinColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(60),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                // Avatar (transparent background so pin color shows through)
                AccountCircle(
                  name: member.name,
                  userId: member.userRemoteId,
                  fileName: member.profilePicture,
                  radius: _circleSize / 2 - 3,
                  backgroundColor: Colors.transparent,
                  textColor: colorScheme.onSurface,
                  isOnline: member.isOnline,
                  showOnlineIndicator: true,
                ),
              ],
            ),

            // ── Pin tail (triangle pointing down) ─────────────────────────────
            Container(
              height: _tailHeight,
              width: _tailWidth,
              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(60),
                    blurRadius: 3,
                    spreadRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _PinTailPainter(color: pinColor),
                size: const Size(_tailWidth, _tailHeight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  final Color color;

  const _PinTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, -3)
      ..lineTo(size.width, -3)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_PinTailPainter old) => color != old.color;
}
