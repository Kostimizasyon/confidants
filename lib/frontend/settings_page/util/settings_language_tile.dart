import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../util/l10n_extensions.dart';

class SettingsLanguageTile extends StatelessWidget {
  final String selectedCode;
  final ValueChanged<String> onLanguageChanged;

  const SettingsLanguageTile({
    super.key,
    required this.selectedCode,
    required this.onLanguageChanged,
  });

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

    final effectiveCode =
        ['system', 'en', 'tr'].contains(selectedCode) ? selectedCode : 'system';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBoxColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                LucideIcons.globe,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.languageTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.languageSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: iconBoxColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: effectiveCode,
                  icon: const Icon(LucideIcons.chevronDown, size: 16),
                  borderRadius: BorderRadius.circular(10),
                  items: [
                    DropdownMenuItem(
                      value: 'system',
                      child: Text(
                        l10n.languageSystem,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(
                        l10n.languageEnglish,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'tr',
                      child: Text(
                        l10n.languageTurkish,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (code) {
                    if (code != null) {
                      onLanguageChanged(code);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
