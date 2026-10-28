import 'package:confidants/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data_models/ai_model_config.dart';
import '../../theme/app_colors.dart';
import '../../util/l10n_extensions.dart';

class ModelSelectorCard extends StatelessWidget {
  final String selectedModelId;
  final ValueChanged<String> onModelChanged;

  const ModelSelectorCard({
    super.key,
    required this.selectedModelId,
    required this.onModelChanged,
  });

  static String titleForId(AppLocalizations l10n, String id) {
    switch (id) {
      case AiModelConfig.idSmolLm2:
        return l10n.aiModelSmolTitle;
      case AiModelConfig.idLlama32OneB:
        return l10n.aiModelLlamaOneTitle;
      case AiModelConfig.idQwen25OneHalfB:
        return l10n.aiModelQwenOneHalfTitle;
      case AiModelConfig.idLlama32ThreeB:
        return l10n.aiModelLlamaThreeTitle;
      case AiModelConfig.idQwen25HalfB:
      default:
        return l10n.aiModelQwenHalfTitle;
    }
  }

  static String specsForId(AppLocalizations l10n, String id) {
    switch (id) {
      case AiModelConfig.idSmolLm2:
        return l10n.aiModelSmolSpecs;
      case AiModelConfig.idLlama32OneB:
        return l10n.aiModelLlamaOneSpecs;
      case AiModelConfig.idQwen25OneHalfB:
        return l10n.aiModelQwenOneHalfSpecs;
      case AiModelConfig.idLlama32ThreeB:
        return l10n.aiModelLlamaThreeSpecs;
      case AiModelConfig.idQwen25HalfB:
      default:
        return l10n.aiModelQwenHalfSpecs;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final effectiveId = AiModelConfig.allModelIds.contains(selectedModelId)
        ? selectedModelId
        : AiModelConfig.idQwen25HalfB;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              initialValue: effectiveId,
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, size: 18),
              decoration: InputDecoration(
                labelText: l10n.aiModelDropdownLabel,
                prefixIcon: const Icon(LucideIcons.cpu, size: 18),
              ),
              selectedItemBuilder: (context) {
                return AiModelConfig.allModelIds.map((id) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      titleForId(l10n, id),
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList();
              },
              items: AiModelConfig.allModelIds.map((id) {
                return DropdownMenuItem<String>(
                  value: id,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          titleForId(l10n, id),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          specsForId(l10n, id),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: secondaryColor,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) onModelChanged(value);
              },
            ),
          ),
        ),
        _buildWarningForId(effectiveId),
      ],
    );
  }

  Widget _buildWarningForId(String id) {
    switch (id) {
      case AiModelConfig.idSmolLm2:
        return const ModelWarningCard.smolLm2();
      case AiModelConfig.idLlama32OneB:
        return const ModelWarningCard.llamaOneB();
      case AiModelConfig.idQwen25OneHalfB:
        return const ModelWarningCard.qwenOneHalfB();
      case AiModelConfig.idLlama32ThreeB:
        return const ModelWarningCard.llamaThreeB();
      case AiModelConfig.idQwen25HalfB:
      default:
        return const ModelWarningCard.qwenHalfB();
    }
  }
}

class ModelWarningCard extends StatelessWidget {
  final IconData icon;
  final L10nText specsOf;
  final L10nText warningOf;
  final bool isHeavyWarning;

  const ModelWarningCard({
    super.key,
    required this.icon,
    required this.specsOf,
    required this.warningOf,
    this.isHeavyWarning = false,
  });

  const ModelWarningCard.smolLm2({super.key})
      : icon = LucideIcons.feather,
        specsOf = _smolSpecs,
        warningOf = _smolWarning,
        isHeavyWarning = false;

  const ModelWarningCard.qwenHalfB({super.key})
      : icon = LucideIcons.gauge,
        specsOf = _qwenHalfSpecs,
        warningOf = _qwenHalfWarning,
        isHeavyWarning = false;

  const ModelWarningCard.llamaOneB({super.key})
      : icon = LucideIcons.memoryStick,
        specsOf = _llamaOneSpecs,
        warningOf = _llamaOneWarning,
        isHeavyWarning = false;

  const ModelWarningCard.qwenOneHalfB({super.key})
      : icon = LucideIcons.hardDrive,
        specsOf = _qwenOneHalfSpecs,
        warningOf = _qwenOneHalfWarning,
        isHeavyWarning = true;

  const ModelWarningCard.llamaThreeB({super.key})
      : icon = LucideIcons.triangleAlert,
        specsOf = _llamaThreeSpecs,
        warningOf = _llamaThreeWarning,
        isHeavyWarning = true;

  static String _smolSpecs(AppLocalizations l10n) => l10n.aiModelSmolSpecs;
  static String _smolWarning(AppLocalizations l10n) => l10n.aiModelSmolWarning;
  static String _qwenHalfSpecs(AppLocalizations l10n) =>
      l10n.aiModelQwenHalfSpecs;
  static String _qwenHalfWarning(AppLocalizations l10n) =>
      l10n.aiModelQwenHalfWarning;
  static String _llamaOneSpecs(AppLocalizations l10n) =>
      l10n.aiModelLlamaOneSpecs;
  static String _llamaOneWarning(AppLocalizations l10n) =>
      l10n.aiModelLlamaOneWarning;
  static String _qwenOneHalfSpecs(AppLocalizations l10n) =>
      l10n.aiModelQwenOneHalfSpecs;
  static String _qwenOneHalfWarning(AppLocalizations l10n) =>
      l10n.aiModelQwenOneHalfWarning;
  static String _llamaThreeSpecs(AppLocalizations l10n) =>
      l10n.aiModelLlamaThreeSpecs;
  static String _llamaThreeWarning(AppLocalizations l10n) =>
      l10n.aiModelLlamaThreeWarning;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final accentColor = isHeavyWarning
        ? AppColors.error
        : (isDark ? AppColors.accentHighlight : AppColors.primaryDarkBlue);
    final badgeBg =
        isDark ? AppColors.secondaryDarkBlue : AppColors.backgroundLight;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isHeavyWarning
              ? AppColors.error
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 17, color: accentColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    specsOf(l10n),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              warningOf(l10n),
              style: theme.textTheme.bodySmall?.copyWith(
                color: secondaryColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
