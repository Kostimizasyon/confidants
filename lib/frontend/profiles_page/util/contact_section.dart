import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data_models/user_profile.dart';
import '../../theme/app_colors.dart';
import '../../util/contact_avatar.dart';
import '../../util/l10n_extensions.dart';

/// Section letter header (`&`, `A`–`Z`, `#`) shown above each contact group.
class ContactSectionHeader extends StatelessWidget {
  final String letter;

  const ContactSectionHeader({super.key, required this.letter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 8),
      child: Text(
        letter,
        style: theme.textTheme.labelLarge?.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// A single contact row. Consecutive rows in a section form one rounded card:
/// [isFirst] / [isLast] control the corner rounding and the inset divider.
class ContactListTile extends StatelessWidget {
  final UserProfile profile;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ContactListTile({
    super.key,
    required this.profile,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final starColor =
        isDark ? AppColors.accentHighlight : AppColors.primaryDarkBlue;
    const radius = Radius.circular(20);
    final name =
        profile.name.trim().isNotEmpty ? profile.name.trim() : l10n.unnamedProfile;

    return Material(
      color: surface,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? radius : Radius.zero,
        bottom: isLast ? radius : Radius.zero,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              ContactAvatar(profile: profile, size: 44),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 68,
                  padding: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    border: isLast
                        ? null
                        : Border(bottom: BorderSide(color: borderColor, width: 1)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (profile.isFavorite)
                        Icon(LucideIcons.star, size: 14, color: starColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
