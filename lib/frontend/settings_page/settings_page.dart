import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../services/auth_service.dart';
import '../../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../util/custom_app_bar.dart';
import '../util/l10n_extensions.dart';
import '../util/proteinbar.dart';
import 'util/model_selector_card.dart';
import 'util/settings_language_tile.dart';
import 'util/settings_toggle_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final PreferencesService _prefs = PreferencesService.instance;
  final AuthService _authService = AuthService.instance;

  Future<void> _handleLanguageChanged(String code) async {
    final l10n = context.l10n;
    await _prefs.setLocaleCode(code);
    if (!mounted) return;
    final langName = switch (code) {
      'en' => l10n.languageEnglish,
      'tr' => l10n.languageTurkish,
      _ => l10n.languageSystem,
    };
    proteinBar(
      context,
      l10n.languageSwitchedToast(langName),
      icon: LucideIcons.globe,
    );
  }

  Future<void> _handleFingerprintToggle(bool requestedValue) async {
    final l10n = context.l10n;

    if (requestedValue) {
      final available = await _authService.isBiometricsAvailable();
      if (!available) {
        if (!mounted) return;
        proteinBar(
          context,
          l10n.biometricsUnavailable,
          icon: LucideIcons.circleAlert,
        );
        return;
      }

      final verified = await _authService.authenticate(
        reason: l10n.authEnableReason,
      );
      if (!verified) return;
    }

    await _prefs.setRequireFingerprintLock(requestedValue);
  }

  Future<void> _handleModelDropdownChanged(String modelId) async {
    final l10n = context.l10n;
    await _prefs.setSelectedModelId(modelId);
    if (!mounted) return;
    proteinBar(
      context,
      l10n.aiModelSwitchedToast(ModelSelectorCard.titleForId(l10n, modelId)),
      icon: LucideIcons.cpu,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sectionColor =
        isDark ? AppColors.accentHighlight : AppColors.primaryDarkBlue;

    return Scaffold(
      appBar: const CustomAppBar.settings(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ValueListenableBuilder<String>(
            valueListenable: _prefs.languageCodeNotifier,
            builder: (context, languageCode, _) {
              return SettingsLanguageTile(
                selectedCode: languageCode,
                onLanguageChanged: _handleLanguageChanged,
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _prefs.isDarkModeNotifier,
            builder: (context, isDarkMode, _) {
              return SettingsToggleTile.theme(
                isDark: isDarkMode,
                onChanged: (value) => _prefs.setDarkMode(value),
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _prefs.requireFingerprintLockNotifier,
            builder: (context, isLockEnabled, _) {
              return SettingsToggleTile.biometrics(
                isEnabled: isLockEnabled,
                onChanged: _handleFingerprintToggle,
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _prefs.isAiEnabledNotifier,
            builder: (context, isAiEnabled, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingsToggleTile.aiOptIn(
                    isEnabled: isAiEnabled,
                    onChanged: (value) => _prefs.setAiEnabled(value),
                  ),
                  if (isAiEnabled) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        l10n.aiModelSectionTitle,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: sectionColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    ValueListenableBuilder<String>(
                      valueListenable: _prefs.selectedModelIdNotifier,
                      builder: (context, selectedId, _) {
                        return ModelSelectorCard(
                          selectedModelId: selectedId,
                          onModelChanged: _handleModelDropdownChanged,
                        );
                      },
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
