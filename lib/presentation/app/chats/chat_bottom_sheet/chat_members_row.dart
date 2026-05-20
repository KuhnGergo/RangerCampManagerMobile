import 'package:flutter/material.dart';
import 'package:mastercs_mobile/models/chat_member.dart';
import 'package:mastercs_mobile/presentation/components/user_profile/user_profile_screen.dart';
import 'package:mastercs_mobile/presentation/components/widgets/account_circle.dart';

class ChatMembersRow extends StatelessWidget {
  const ChatMembersRow({
    super.key,
    required this.members,
    required this.colorScheme,
  });

  final List<ChatMember> members;
  final ColorScheme colorScheme;

  void _openProfileScreen(BuildContext context, ChatMember member) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(userId: member.userRemoteId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayMembers = members.take(8).toList();
    final hasMore = members.length > 8;

    return SizedBox(
      height: 48,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 8,
          children: [
            for (final member in displayMembers)
              InkWell(
                onTap: () => _openProfileScreen(context, member),
                customBorder: const CircleBorder(),
                child: AccountCircle(
                  name: member.name,
                  userId: member.userRemoteId,
                  fileName: member.profilePicturePath,
                  radius: 20,
                ),
              ),
            if (hasMore)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '+${members.length - 8}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
