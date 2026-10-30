import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data_models/user_profile.dart';
import '../../theme/app_colors.dart';
import '../../util/contact_avatar.dart';
import '../../util/l10n_extensions.dart';

/// One UI-style "Favorites" header followed by a 3-column grid of tiles.
class FavoritesGrid extends StatelessWidget {
  final List<UserProfile> favorites;
  final ValueChanged<UserProfile> onTap;
  final ValueChanged<UserProfile> onLongPress;

  const FavoritesGrid({
    super.key,
    required this.favorites,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
          child: Row(
            children: [
              Icon(LucideIcons.star, size: 16, color: secondaryColor),
              const SizedBox(width: 8),
              Text(
                l10n.favoritesSectionTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: secondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final profile = favorites[index];
            return _FavoriteTile(
              profile: profile,
              gradientIndex: index,
              onTap: () => onTap(profile),
              onLongPress: () => onLongPress(profile),
            );
          },
        ),
      ],
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  final UserProfile profile;
  final int gradientIndex;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _FavoriteTile({
    required this.profile,
    required this.gradientIndex,
    required this.onTap,
    required this.onLongPress,
  });

  // Rotating vibrant One UI pastel gradients built strictly from palette tokens.
  static const List<List<Color>> _gradients = [
    [AppColors.gradientPeachStart, AppColors.gradientPeachEnd],
    [AppColors.gradientSkyStart, AppColors.gradientSkyEnd],
    [AppColors.gradientBlueStart, AppColors.gradientBlueEnd],
    [AppColors.gradientLavenderStart, AppColors.gradientLavenderEnd],
    [AppColors.gradientMintStart, AppColors.gradientMintEnd],
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final name =
        profile.name.trim().isNotEmpty ? profile.name.trim() : l10n.unnamedProfile;

    return Material(
      color: AppColors.transparent,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _gradients[gradientIndex % _gradients.length],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size = constraints.biggest.shortestSide.clamp(36.0, 72.0);
                        return ContactAvatar.favorite(profile: profile, size: size);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.surfaceLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
