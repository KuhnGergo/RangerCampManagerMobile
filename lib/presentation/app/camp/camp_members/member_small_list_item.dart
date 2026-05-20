import 'package:flutter/material.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/presentation/components/widgets/account_circle.dart';
import 'package:mastercs_mobile/presentation/components/user_profile/user_profile_screen.dart';

class MemberSmallListItem extends StatelessWidget {
  final Member member;
  final Color? backgroundColor;

  const MemberSmallListItem({
    super.key,
    required this.member,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bgColor = backgroundColor ?? Colors.transparent;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  UserProfileScreen(userId: member.userRemoteId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AccountCircle(
                name: member.name,
                userId: member.userRemoteId,
                fileName: member.profilePicture,
                isOnline: member.isOnline,
                role: member.role,
                radius: 16,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      member.name,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (member.role == 'Owner') ...[
                      SizedBox(width: 4),
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
