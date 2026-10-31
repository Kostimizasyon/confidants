import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data_models/contact_item.dart';
import '../theme/app_colors.dart';
import 'l10n_extensions.dart';

class ContactPickerDialog extends StatefulWidget {
  final List<ContactItem> contacts;
  final VoidCallback? onImportAll;

  const ContactPickerDialog({
    super.key,
    required this.contacts,
    this.onImportAll,
  });

  static Future<ContactItem?> show(
    BuildContext context, {
    required List<ContactItem> contacts,
    VoidCallback? onImportAll,
  }) {
    return showModalBottomSheet<ContactItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => ContactPickerDialog(
        contacts: contacts,
        onImportAll: onImportAll,
      ),
    );
  }

  @override
  State<ContactPickerDialog> createState() => _ContactPickerDialogState();
}

class _ContactPickerDialogState extends State<ContactPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  late List<ContactItem> _filteredContacts;

  @override
  void initState() {
    super.initState();
    _filteredContacts = widget.contacts;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final trimmed = query.trim().toLowerCase();
    setState(() {
      if (trimmed.isEmpty) {
        _filteredContacts = widget.contacts;
      } else {
        _filteredContacts = widget.contacts.where((c) {
          return c.displayName.toLowerCase().contains(trimmed) ||
              c.phoneNumber.toLowerCase().contains(trimmed);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final badgeColor =
        isDark ? AppColors.secondaryDarkBlue : AppColors.primaryDarkBlue;

    return FractionallySizedBox(
      heightFactor: 0.82,
      child: Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.bookUser,
                      size: 18,
                      color: AppColors.surfaceLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.importDeviceContactTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(LucideIcons.x, size: 20),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: l10n.searchContactsHint,
                  prefixIcon: const Icon(LucideIcons.search, size: 18),
                ),
              ),
            ),
            if (widget.contacts.isNotEmpty && widget.onImportAll != null) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onImportAll?.call();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: badgeColor,
                      foregroundColor: AppColors.surfaceLight,
                    ),
                    icon: const Icon(LucideIcons.users, size: 18),
                    label: Text(
                      l10n.importAllContactsButton(widget.contacts.length),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1),
            Expanded(
              child: _filteredContacts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.noMatchingContacts,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: _filteredContacts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = _filteredContacts[index];
                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            onTap: () => Navigator.of(context).pop(item),
                            leading: CircleAvatar(
                              backgroundColor: badgeColor,
                              foregroundColor: AppColors.surfaceLight,
                              child: const Icon(LucideIcons.user, size: 18),
                            ),
                            title: Text(
                              item.displayName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              item.phoneNumber,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: secondaryTextColor,
                              ),
                            ),
                            trailing: const Icon(
                              LucideIcons.plus,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
