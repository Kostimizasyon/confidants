import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:confidants/l10n/app_localizations.dart';
import '../settings_page/settings_page.dart';
import '../theme/app_colors.dart';
import 'l10n_extensions.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final IconData leadingIcon;
  final L10nText titleOf;
  final L10nText? subtitleOf;
  final List<Widget>? actions;
  final bool showBackButton;

  /// Appends the top-right Settings button (used by the three main tabs).
  final bool showSettingsAction;

  const CustomAppBar({
    super.key,
    required this.leadingIcon,
    required this.titleOf,
    this.subtitleOf,
    this.actions,
    this.showBackButton = false,
    this.showSettingsAction = false,
  });

  const CustomAppBar.dialer({
    super.key,
    this.actions,
    L10nText? titleOf,
    L10nText? subtitleOf,
    IconData? leadingIcon,
  })  : leadingIcon = leadingIcon ?? LucideIcons.grid3x3,
        titleOf = titleOf ?? _dialerTitle,
        subtitleOf = subtitleOf ?? _dialerSubtitle,
        showBackButton = false,
        showSettingsAction = true;

  const CustomAppBar.chat({
    super.key,
    this.actions,
  })  : leadingIcon = LucideIcons.bot,
        titleOf = _chatTitle,
        subtitleOf = _chatSubtitle,
        showBackButton = false,
        showSettingsAction = true;

  const CustomAppBar.profiles({
    super.key,
    this.actions,
  })  : leadingIcon = LucideIcons.users,
        titleOf = _profilesTitle,
        subtitleOf = _profilesSubtitle,
        showBackButton = false,
        showSettingsAction = true;

  /// Settings is now a pushed route, so it shows a back button instead of tabs.
  const CustomAppBar.settings({
    super.key,
    this.actions,
  })  : leadingIcon = LucideIcons.slidersHorizontal,
        titleOf = _settingsTitle,
        subtitleOf = _settingsSubtitle,
        showBackButton = true,
        showSettingsAction = false;

  /// [title] is dynamic (a profile name or an already-localized string).
  CustomAppBar.detail({
    super.key,
    required String title,
    this.actions,
  })  : leadingIcon = LucideIcons.userCheck,
        titleOf = ((_) => title),
        subtitleOf = _detailSubtitle,
        showBackButton = true,
        showSettingsAction = false;

  static String _dialerTitle(AppLocalizations l10n) => l10n.dialerTitle;
  static String _dialerSubtitle(AppLocalizations l10n) => l10n.dialerSubtitle;
  static String _chatTitle(AppLocalizations l10n) => l10n.chatTitle;
  static String _chatSubtitle(AppLocalizations l10n) => l10n.chatSubtitle;
  static String _profilesTitle(AppLocalizations l10n) => l10n.profilesTitle;
  static String _profilesSubtitle(AppLocalizations l10n) =>
      l10n.profilesSubtitle;
  static String _settingsTitle(AppLocalizations l10n) => l10n.settingsTitle;
  static String _settingsSubtitle(AppLocalizations l10n) =>
      l10n.settingsSubtitle;
  static String _detailSubtitle(AppLocalizations l10n) => l10n.detailSubtitle;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final badgeBackground =
        isDark ? AppColors.secondaryDarkBlue : AppColors.primaryDarkBlue;
    final subtitle = subtitleOf?.call(l10n);

    final mergedActions = <Widget>[
      ...?actions,
      if (showSettingsAction)
        IconButton(
          onPressed: () => _openSettings(context),
          icon: const Icon(LucideIcons.settings, size: 20),
          tooltip: l10n.settingsTooltip,
        ),
      if (showSettingsAction) const SizedBox(width: 4),
    ];

    return AppBar(
      automaticallyImplyLeading: showBackButton,
      toolbarHeight: 68,
      titleSpacing: showBackButton ? 0 : 16,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: badgeBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              leadingIcon,
              size: 19,
              color: AppColors.surfaceLight,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titleOf(l10n),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      actions: mergedActions.isEmpty ? null : mergedActions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: borderColor,
        ),
      ),
    );
  }
}
