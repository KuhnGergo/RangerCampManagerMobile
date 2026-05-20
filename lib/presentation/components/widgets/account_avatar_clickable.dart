import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/api/api_provider.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/presentation/components/widgets/account_circle.dart';
import 'package:mastercs_mobile/presentation/components/user_profile/user_profile_screen.dart';

/// A clickable avatar widget that displays a user's profile picture
/// and navigates to their profile screen when tapped.
///
/// Accepts a raw filename ([profilePictureFilename]) and resolves it to
/// a full URL using [apiConfigProvider].
class AccountAvatarClickable extends ConsumerWidget {
  final String name;
  final String userId;

  /// Raw filename stored in local DB (e.g. "abc123.png").
  /// Set to null if the user has no profile picture.
  final String? profilePictureFilename;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final Member? user;

  const AccountAvatarClickable({
    super.key,
    required this.name,
    required this.userId,
    this.profilePictureFilename,
    this.radius = 20,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(userId: userId),
          ),
        );
      },
      child: AccountCircle(
        name: name,
        userId: userId,
        fileName: profilePictureFilename,
        radius: radius,
        backgroundColor: backgroundColor,
        textColor: textColor,
        fontSize: fontSize,
      ),
    );
  }
}
