import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/data/image_url_provider.dart';

/// A reusable circular avatar widget that displays a user's profile picture
/// via [CachedNetworkImage] or falls back to the first letter of their name.
class AccountCircle extends ConsumerWidget {
  final String name;
  final String? userId;
  final String? fileName;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final bool isOnline;
  final bool showOnlineIndicator;
  final bool showErrorIndicator;
  final String? role; // 'Owner' or 'Staff' to show badges

  const AccountCircle({
    super.key,
    required this.name,
    this.userId,
    this.fileName,
    this.radius = 20,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.isOnline = false,
    this.showOnlineIndicator = true,
    this.showErrorIndicator = false,
    this.role,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.primary;
    final effectiveTextColor = textColor ?? colorScheme.onPrimary;
    final effectiveFontSize = fontSize ?? radius * 0.8;
    final onlineIndicatorSize = radius * 0.6;
    final onlineIndicatorBorderWidth = radius * 0.08;

    // Don't show role badges if the avatar is too small
    // final showRoleBadge = role != null && radius >= 16;

    Widget avatar;

    if (fileName != null && fileName!.isNotEmpty) {
      final imageUrl = ref
          .read(imageUrlProvider)
          .getProfilePictureUrl(fileName);

      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: effectiveBackgroundColor,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl ?? '',
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                _buildFallbackText(effectiveTextColor, effectiveFontSize),
            errorWidget: (context, url, error) {
              return _buildFallbackText(effectiveTextColor, effectiveFontSize);
            },
          ),
        ),
      );
    } else {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: effectiveBackgroundColor,
        child: _buildFallbackText(effectiveTextColor, effectiveFontSize),
      );
    }

    // Build the stack with online indicator and/or role badge
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,

        // Online indicator (bottom-right)
        if (showOnlineIndicator && isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: onlineIndicatorSize,
              height: onlineIndicatorSize,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: onlineIndicatorBorderWidth,
                ),
              ),
            ),
          ),

        // Error indicator (top-right)
        if (showErrorIndicator)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              width: radius * 0.8,
              height: radius * 0.8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.priority_high,
                size: radius * 0.7,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFallbackText(Color textColor, double fontSize) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
