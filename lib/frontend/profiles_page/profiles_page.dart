import 'package:confidants/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data_models/contact_item.dart';
import '../../data_models/user_profile.dart';
import '../../services/contact_service.dart';
import '../../services/database_helper.dart';
import '../theme/app_colors.dart';
import '../util/contact_picker_dialog.dart';
import '../util/custom_app_bar.dart';
import '../util/l10n_extensions.dart';
import '../util/proteinbar.dart';
import 'profile_detail_page.dart';
import 'util/profile_card.dart';

class ProfilesPage extends StatefulWidget {
  const ProfilesPage({super.key});

  @override
  State<ProfilesPage> createState() => _ProfilesPageState();
}

class _ProfilesPageState extends State<ProfilesPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ContactService _contactService = ContactService.instance;
  final TextEditingController _searchController = TextEditingController();

  List<UserProfile> _profiles = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProfiles([String? query]) async {
    final loaded = await _dbHelper.getAllProfiles(
      searchQuery: query ?? _searchController.text,
    );
    if (!mounted) return;
    setState(() {
      _profiles = loaded;
      _isLoading = false;
    });
  }

  Future<void> _handleToggleFavorite(UserProfile profile) async {
    final id = profile.id;
    if (id == null) return;
    await _dbHelper.toggleFavorite(id, !profile.isFavorite);
    await _loadProfiles();
  }

  Future<void> _openCreateManual() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProfileDetailPage.create(),
      ),
    );
    if (changed == true) {
      await _loadProfiles();
    }
  }

  Future<void> _openImportContact() async {
    final l10n = context.l10n;
    final contacts = await _contactService.fetchDeviceContacts();
    if (!mounted) return;

    if (contacts.isEmpty) {
      proteinBar(
        context,
        l10n.noContactsFound,
        icon: LucideIcons.bookUser,
      );
      return;
    }

    final selected = await ContactPickerDialog.show(
      context,
      contacts: contacts,
    );
    if (!mounted || selected == null) return;

    await _openCreateFromContact(selected);
  }

  Future<void> _openCreateFromContact(ContactItem contact) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProfileDetailPage.create(contact: contact),
      ),
    );
    if (changed == true) {
      await _loadProfiles();
    }
  }

  Future<void> _openEditProfile(UserProfile profile) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProfileDetailPage.edit(profile: profile),
      ),
    );
    if (changed == true) {
      await _loadProfiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonBg =
        isDark ? AppColors.secondaryDarkBlue : AppColors.primaryDarkBlue;
    final hasSearchQuery = _searchController.text.trim().isNotEmpty;
    final hasProfiles = _profiles.isNotEmpty;

    return Scaffold(
      appBar: CustomAppBar.profiles(
        actions: hasProfiles
            ? [
                IconButton(
                  onPressed: _openImportContact,
                  icon: const Icon(LucideIcons.bookUser, size: 20),
                  tooltip: l10n.importFromContactsTooltip,
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _loadProfiles,
              decoration: InputDecoration(
                hintText: l10n.searchProfilesHint,
                prefixIcon: const Icon(LucideIcons.search, size: 18),
                suffixIcon: hasSearchQuery
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          _loadProfiles('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _profiles.isEmpty
                    ? (hasSearchQuery
                        ? const _ProfilesEmptyState.search()
                        : _ProfilesEmptyState.initial(
                            onImport: _openImportContact,
                            onCreateManual: _openCreateManual,
                          ))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _profiles.length,
                        itemBuilder: (context, index) {
                          final profile = _profiles[index];
                          return ProfileCard.compact(
                            profile: profile,
                            onTap: () => _openEditProfile(profile),
                            onToggleFavorite: () =>
                                _handleToggleFavorite(profile),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: hasProfiles
          ? FloatingActionButton.extended(
              onPressed: _openCreateManual,
              backgroundColor: buttonBg,
              foregroundColor: AppColors.surfaceLight,
              icon: const Icon(LucideIcons.userPlus, size: 18),
              label: Text(l10n.addProfileButton),
            )
          : null,
    );
  }
}

class _ProfilesEmptyState extends StatelessWidget {
  final IconData icon;
  final L10nText titleOf;
  final L10nText subtitleOf;
  final VoidCallback? onImport;
  final VoidCallback? onCreateManual;

  const _ProfilesEmptyState.initial({
    required VoidCallback this.onImport,
    required VoidCallback this.onCreateManual,
  })  : icon = LucideIcons.users,
        titleOf = _initialTitle,
        subtitleOf = _initialSubtitle;

  const _ProfilesEmptyState.search()
      : icon = LucideIcons.searchX,
        titleOf = _searchTitle,
        subtitleOf = _searchSubtitle,
        onImport = null,
        onCreateManual = null;

  static String _initialTitle(AppLocalizations l10n) => l10n.emptyInitialTitle;
  static String _initialSubtitle(AppLocalizations l10n) =>
      l10n.emptyInitialSubtitle;
  static String _searchTitle(AppLocalizations l10n) => l10n.emptySearchTitle;
  static String _searchSubtitle(AppLocalizations l10n) =>
      l10n.emptySearchSubtitle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconBoxColor =
        isDark ? AppColors.secondaryDarkBlue : AppColors.backgroundLight;
    final iconColor =
        isDark ? AppColors.accentHighlight : AppColors.primaryDarkBlue;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primaryBtnBg =
        isDark ? AppColors.secondaryDarkBlue : AppColors.primaryDarkBlue;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconBoxColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 30, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              titleOf(l10n),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitleOf(l10n),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (onImport != null && onCreateManual != null) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: onImport,
                    icon: const Icon(LucideIcons.bookUser, size: 16),
                    label: Text(l10n.importContactButton),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: onCreateManual,
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryBtnBg,
                      foregroundColor: AppColors.surfaceLight,
                    ),
                    icon: const Icon(LucideIcons.userPlus, size: 16),
                    label: Text(l10n.createManuallyButton),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
