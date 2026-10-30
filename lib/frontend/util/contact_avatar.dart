import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data_models/user_profile.dart';
import '../../services/contact_index.dart';
import '../theme/app_colors.dart';
import 'avatar_icon_helper.dart';

/// Circular contact avatar.
/// - A custom avatar icon (anything other than the default `user`) wins.
/// - Otherwise names starting with A–Z show their initial.
/// - Emoji / symbol / digit names fall back to a person icon.
class ContactAvatar extends StatelessWidget {
  final UserProfile profile;
  final double size;
  final bool isOutlined;

  const ContactAvatar({
    super.key,
    required this.profile,
    this.size = 40,
    this.isOutlined = false,
  });

  /// Large translucent-ring variant used inside favorite grid tiles.
  const ContactAvatar.favorite({
    super.key,
    required this.profile,
    this.size = 64,
  }) : isOutlined = true;

  @override
  Widget build(BuildContext context) {
    final hasCustomIcon = profile.avatarIcon != 'user';
    final initial =
        hasCustomIcon ? null : ContactIndex.avatarInitialFor(profile.name);

    final Widget content = initial != null
        ? Text(
            initial,
            style: TextStyle(
              color: AppColors.surfaceLight,
              fontSize: size * (isOutlined ? 0.5 : 0.45),
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          )
        : Icon(
            hasCustomIcon
                ? AvatarIconHelper.resolve(profile.avatarIcon)
                : LucideIcons.user,
            size: size * 0.48,
            color: AppColors.surfaceLight,
          );

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOutlined ? AppColors.surfaceLight.withValues(alpha: 0.12) : null,
        gradient: isOutlined
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.avatarGradientStart,
                  AppColors.avatarGradientEnd,
                ],
              ),
        border: isOutlined
            ? Border.all(
                color: AppColors.surfaceLight.withValues(alpha: 0.65),
                width: 1.5,
              )
            : null,
      ),
      child: content,
    );
  }
}
