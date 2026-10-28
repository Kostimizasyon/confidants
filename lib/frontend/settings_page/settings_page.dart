import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data_models/ai_model_config.dart';
import '../../services/auth_service.dart';
import '../../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../util/custom_app_bar.dart';
import '../util/l10n_extensions.dart';
import '../util/proteinbar.dart';
import 'util/model_selector_card.dart';
import 'util/settings_toggle_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final PreferencesService _prefs = PreferencesService.instance;
  final AuthService _authService = AuthService.instance;

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
    if (modelId == AiModelConfig.idCustom) {
      await _prefs.setSelectedModelId(modelId);
      if (_prefs.customModelPath == null ||
          _prefs.customModelPath!.trim().isEmpty) {
        await _promptCustomModelPath();
      }
      return;
    }

    await _prefs.setSelectedModelId(modelId);
    if (!mounted) return;
    proteinBar(
      context,
      l10n.aiModelSwitchedToast(ModelSelectorCard.titleForId(l10n, modelId)),
      icon: LucideIcons.cpu,
    );
  }

  Future<void> _promptCustomModelPath() async {
    final l10n = context.l10n;
    final controller = TextEditingController(
      text: _prefs.customModelPath ?? '',
    );

    final chosenPath = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        final btnBg =
            isDark ? AppColors.secondaryDarkBlue : AppColors.primaryDarkBlue;

        return AlertDialog(
          title: Text(l10n.aiModelCustomDialogTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: l10n.aiModelCustomPathLabel,
              hintText: l10n.aiModelCustomPathHint,
              prefixIcon: const Icon(LucideIcons.fileCode, size: 18),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.aiModelCustomCancelButton),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              style: FilledButton.styleFrom(
                backgroundColor: btnBg,
                foregroundColor: AppColors.surfaceLight,
              ),
              child: Text(l10n.aiModelCustomSaveButton),
            ),
          ],
        );
      },
    );

    controller.dispose();
    if (!mounted || chosenPath == null) return;

    if (chosenPath.isEmpty || !chosenPath.toLowerCase().endsWith('.gguf')) {
      proteinBar(
        context,
        l10n.aiModelCustomInvalidToast,
        icon: LucideIcons.circleAlert,
      );
      return;
    }

    await _prefs.setCustomModelPath(chosenPath);
    await _prefs.setSelectedModelId(AiModelConfig.idCustom);
    if (!mounted) return;

    proteinBar(
      context,
      l10n.aiModelSwitchedToast(l10n.aiModelCustomTitle),
      icon: LucideIcons.folderCheck,
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
                        return ValueListenableBuilder<String?>(
                          valueListenable: _prefs.customModelPathNotifier,
                          builder: (context, customPath, _) {
                            return ModelSelectorCard(
                              selectedModelId: selectedId,
                              customFilePath: customPath,
                              onModelChanged: _handleModelDropdownChanged,
                              onPickCustomPath: _promptCustomModelPath,
                            );
                          },
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
