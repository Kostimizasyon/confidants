import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data_models/custom_field.dart';
import '../../theme/app_colors.dart';
import '../../util/l10n_extensions.dart';

class CustomFieldEditor extends StatelessWidget {
  final List<CustomField> fields;
  final ValueChanged<List<CustomField>> onChanged;

  const CustomFieldEditor({
    super.key,
    required this.fields,
    required this.onChanged,
  });

  void _addField() {
    onChanged([
      ...fields,
      const CustomField.draft(fieldKey: '', fieldValue: ''),
    ]);
  }

  void _updateKey(int index, String newKey) {
    final updated = List<CustomField>.from(fields);
    updated[index] = updated[index].copyWith(fieldKey: newKey);
    onChanged(updated);
  }

  void _updateValue(int index, String newValue) {
    final updated = List<CustomField>.from(fields);
    updated[index] = updated[index].copyWith(fieldValue: newValue);
    onChanged(updated);
  }

  void _removeField(int index) {
    final updated = List<CustomField>.from(fields)..removeAt(index);
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final buttonBg =
        isDark ? AppColors.secondaryDarkBlue : AppColors.primaryDarkBlue;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.sparkles,
                  size: 18,
                  color: isDark
                      ? AppColors.accentHighlight
                      : AppColors.primaryDarkBlue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.customAttributesTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addField,
                  style: TextButton.styleFrom(
                    foregroundColor: isDark
                        ? AppColors.accentHighlight
                        : AppColors.primaryDarkBlue,
                  ),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: Text(l10n.addRowButton),
                ),
              ],
            ),
            if (fields.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.customAttributesEmptyHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: secondaryColor,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 12),
                itemCount: fields.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = fields[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: item.fieldKey,
                          onChanged: (val) => _updateKey(index, val),
                          decoration: InputDecoration(
                            labelText: l10n.attributeLabel,
                            hintText: l10n.attributeHint,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          initialValue: item.fieldValue,
                          onChanged: (val) => _updateValue(index, val),
                          decoration: InputDecoration(
                            labelText: l10n.valueLabel,
                            hintText: l10n.valueHint,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () => _removeField(index),
                        icon: const Icon(
                          LucideIcons.trash2,
                          size: 18,
                          color: AppColors.error,
                        ),
                        tooltip: l10n.removeAttributeTooltip,
                      ),
                    ],
                  );
                },
              ),
            if (fields.isNotEmpty) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: _addField,
                  style: FilledButton.styleFrom(
                    backgroundColor: buttonBg,
                    foregroundColor: AppColors.surfaceLight,
                  ),
                  icon: const Icon(LucideIcons.plus, size: 15),
                  label: Text(l10n.addAnotherButton),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
