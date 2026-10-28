import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data_models/user_profile.dart';
import '../../theme/app_colors.dart';
import '../../util/l10n_extensions.dart';

class ProfileCard extends StatelessWidget {
  final UserProfile profile;
  final bool isDetailed;
  final VoidCallback? onTap;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.isDetailed,
    this.onTap,
  });

  const ProfileCard.compact({
    super.key,
    required this.profile,
    required VoidCallback this.onTap,
  }) : isDetailed = false;

  const ProfileCard.detailed({
    super.key,
    required this.profile,
  })  : isDetailed = true,
        onTap = null;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final badgeBg =
        isDark ? AppColors.secondaryDarkBlue : AppColors.primaryDarkBlue;
    final chipBg =
        isDark ? AppColors.secondaryDarkBlue : AppColors.backgroundLight;
    final chipTextColor =
        isDark ? AppColors.accentHighlight : AppColors.primaryDarkBlue;

    final displayName =
        profile.name.trim().isNotEmpty ? profile.name.trim() : l10n.unnamedProfile;
    final nickname = profile.nickname?.trim() ?? '';
    final shortHash = profile.profileHash.length >= 10
        ? profile.profileHash.substring(0, 10)
        : profile.profileHash;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.user,
                      size: 20,
                      color: AppColors.surfaceLight,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.phone,
                              size: 13,
                              color: secondaryColor,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                profile.phoneNumber.isNotEmpty
                                    ? profile.phoneNumber
                                    : l10n.noPhoneNumber,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: secondaryColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          profile.isTrainingEnabled
                              ? LucideIcons.brainCircuit
                              : LucideIcons.eyeOff,
                          size: 14,
                          color: profile.isTrainingEnabled
                              ? chipTextColor
                              : secondaryColor,
                        ),
                        if (nickname.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            nickname,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: chipTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!isDetailed) ...[
                    const SizedBox(width: 8),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: secondaryColor,
                    ),
                  ],
                ],
              ),
              if (isDetailed) ...[
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.hash, size: 14, color: secondaryColor),
                        const SizedBox(width: 4),
                        Text(
                          l10n.sha256Label('$shortHash...'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    if (profile.birthday != null &&
                        profile.birthday!.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.cake,
                            size: 14,
                            color: secondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            profile.birthday!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.listPlus,
                          size: 14,
                          color: secondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.customAttributesCount(
                            profile.customFields.length,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
