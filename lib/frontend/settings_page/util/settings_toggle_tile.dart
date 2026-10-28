import 'package:confidants/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../util/l10n_extensions.dart';

class SettingsToggleTile extends StatelessWidget {
  final IconData icon;
  final L10nText titleOf;
  final L10nText subtitleOf;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsToggleTile({
    super.key,
    required this.icon,
    required this.titleOf,
    required this.subtitleOf,
    required this.value,
    required this.onChanged,
  });

  const SettingsToggleTile.theme({
    super.key,
    required bool isDark,
    required this.onChanged,
  })  : value = isDark,
        icon = isDark ? LucideIcons.moon : LucideIcons.sun,
        titleOf = _darkModeTitle,
        subtitleOf = isDark ? _darkModeSubtitleOn : _darkModeSubtitleOff;

  const SettingsToggleTile.biometrics({
    super.key,
    required bool isEnabled,
    required this.onChanged,
  })  : value = isEnabled,
        icon = LucideIcons.fingerprint,
        titleOf = _biometricTitle,
        subtitleOf = _biometricSubtitle;

  const SettingsToggleTile.training({
    super.key,
    required bool isEnabled,
    required this.onChanged,
  })  : value = isEnabled,
        icon = LucideIcons.brainCircuit,
        titleOf = _trainingTitle,
        subtitleOf = _trainingSubtitle;

  const SettingsToggleTile.aiOptIn({
    super.key,
    required bool isEnabled,
    required this.onChanged,
  })  : value = isEnabled,
        icon = LucideIcons.bot,
        titleOf = _aiOptInTitle,
        subtitleOf = _aiOptInSubtitle;

  static String _darkModeTitle(AppLocalizations l10n) => l10n.darkModeTitle;
  static String _darkModeSubtitleOn(AppLocalizations l10n) =>
      l10n.darkModeSubtitleOn;
  static String _darkModeSubtitleOff(AppLocalizations l10n) =>
      l10n.darkModeSubtitleOff;
  static String _biometricTitle(AppLocalizations l10n) =>
      l10n.biometricLockTitle;
  static String _biometricSubtitle(AppLocalizations l10n) =>
      l10n.biometricLockSubtitle;
  static String _trainingTitle(AppLocalizations l10n) => l10n.trainingTitle;
  static String _trainingSubtitle(AppLocalizations l10n) =>
      l10n.trainingSubtitle;
  static String _aiOptInTitle(AppLocalizations l10n) => l10n.aiOptInTitle;
  static String _aiOptInSubtitle(AppLocalizations l10n) => l10n.aiOptInSubtitle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final iconBoxColor =
        isDark ? AppColors.secondaryDarkBlue : AppColors.backgroundLight;
    final iconColor =
        isDark ? AppColors.accentHighlight : AppColors.primaryDarkBlue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBoxColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
        title: Text(
          titleOf(l10n),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitleOf(l10n),
            style: theme.textTheme.bodySmall?.copyWith(
              color: secondaryTextColor,
            ),
          ),
        ),
        value: value,
        activeThumbColor: AppColors.surfaceLight,
        activeTrackColor:
            isDark ? AppColors.accentBlue : AppColors.primaryDarkBlue,
        onChanged: onChanged,
      ),
    );
  }
}
