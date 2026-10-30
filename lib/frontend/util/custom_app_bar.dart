import 'package:confidants/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../settings_page/settings_page.dart';
import '../theme/app_colors.dart';
import 'l10n_extensions.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final L10nText? titleOf;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;

  /// Appends the top-right 3-dots Settings button (used by the three main tabs).
  final bool showSettingsAction;

  const CustomAppBar({
    super.key,
    this.titleOf,
    this.titleWidget,
    this.leading,
    this.actions,
    this.showBackButton = false,
    this.showSettingsAction = false,
  });

  const CustomAppBar.dialer({
    super.key,
    this.actions,
    this.titleOf,
    this.titleWidget,
    this.leading,
  })  : showBackButton = false,
        showSettingsAction = true;

  const CustomAppBar.chat({
    super.key,
    this.actions,
    this.titleWidget,
    this.leading,
  })  : titleOf = null,
        showBackButton = false,
        showSettingsAction = true;

  const CustomAppBar.profiles({
    super.key,
    this.actions,
    this.titleWidget,
    this.leading,
  })  : titleOf = null,
        showBackButton = false,
        showSettingsAction = true;

  /// Settings is a pushed route, so it shows a back button and simple title.
  const CustomAppBar.settings({
    super.key,
    this.actions,
  })  : titleOf = _settingsTitle,
        titleWidget = null,
        leading = null,
        showBackButton = true,
        showSettingsAction = false;

  /// [title] is dynamic (a confidant name or an already-localized string).
  CustomAppBar.detail({
    super.key,
    required String title,
    this.actions,
  })  : titleOf = ((_) => title),
        titleWidget = null,
        leading = null,
        showBackButton = true,
        showSettingsAction = false;

  static String _settingsTitle(AppLocalizations l10n) => l10n.settingsTitle;

  @override
  Size get preferredSize => const Size.fromHeight(56);

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
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final fgColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final mergedActions = <Widget>[
      ...?actions,
      if (showSettingsAction)
        IconButton(
          onPressed: () => _openSettings(context),
          icon: Icon(LucideIcons.ellipsisVertical, size: 22, color: fgColor),
          tooltip: l10n.settingsTooltip,
        ),
      const SizedBox(width: 4),
    ];

    Widget? resolvedTitle = titleWidget;
    if (resolvedTitle == null && titleOf != null) {
      final text = titleOf!(l10n);
      if (text.isNotEmpty) {
        resolvedTitle = Text(
          text,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: fgColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      }
    }

    return AppBar(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: AppColors.transparent,
      automaticallyImplyLeading: showBackButton,
      leading: leading,
      toolbarHeight: 56,
      titleSpacing: (showBackButton || leading != null) ? 0 : 20,
      title: resolvedTitle,
      actions: mergedActions,
    );
  }
}
