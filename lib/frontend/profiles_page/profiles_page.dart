import 'package:confidants/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data_models/contact_item.dart';
import '../../data_models/user_profile.dart';
import '../../services/contact_index.dart';
import '../../services/contact_service.dart';
import '../../services/database_helper.dart';
import '../../services/export_service.dart';
import '../../services/hash_service.dart';
import '../theme/app_colors.dart';
import '../util/contact_picker_dialog.dart';
import '../util/custom_app_bar.dart';
import '../util/l10n_extensions.dart';
import '../util/proteinbar.dart';
import 'profile_detail_page.dart';
import 'util/contact_section.dart';
import 'util/favorites_grid.dart';

class ProfilesPage extends StatefulWidget {
  const ProfilesPage({super.key});

  @override
  State<ProfilesPage> createState() => _ProfilesPageState();
}

class _ProfilesPageState extends State<ProfilesPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ContactService _contactService = ContactService.instance;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<UserProfile> _profiles = const [];
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
    // Refresh when profiles change elsewhere (e.g. created from the dialer).
    _dbHelper.revision.addListener(_onDatabaseChanged);
  }

  @override
  void dispose() {
    _dbHelper.revision.removeListener(_onDatabaseChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() => _isSearching = true);
    _searchFocusNode.requestFocus();
  }

  void _stopSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() => _isSearching = false);
    _loadProfiles('');
  }

  void _onDatabaseChanged() => _loadProfiles();

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
    final l10n = context.l10n;
    final nowFavorite = !profile.isFavorite;
    await _dbHelper.toggleFavorite(id, nowFavorite);
    if (!mounted) return;
    final name =
        profile.name.trim().isNotEmpty ? profile.name.trim() : l10n.unnamedProfile;
    proteinBar(
      context,
      nowFavorite ? l10n.favoriteAddedToast(name) : l10n.favoriteRemovedToast(name),
      icon: nowFavorite ? LucideIcons.star : LucideIcons.starOff,
    );
  }

  /// Flattens favorites + `&` / A–Z / `#` sections into lazily-built rows.
  List<Widget Function()> _buildRows() {
    final rows = <Widget Function()>[];
    final isSearching = _searchController.text.trim().isNotEmpty;
    final favorites = _profiles.where((p) => p.isFavorite).toList()
      ..sort((a, b) => ContactIndex.foldString(a.name.trim())
          .compareTo(ContactIndex.foldString(b.name.trim())));

    if (!isSearching && favorites.isNotEmpty) {
      rows.add(() => FavoritesGrid(
            favorites: favorites,
            onTap: _openEditProfile,
            onLongPress: _handleToggleFavorite,
          ));
    }

    final sections = ContactIndex.groupBySection<UserProfile>(
      _profiles,
      (p) => p.name,
    );
    for (final section in sections) {
      rows.add(() => ContactSectionHeader(letter: section.key));
      final members = section.value;
      for (var i = 0; i < members.length; i++) {
        final profile = members[i];
        final isFirst = i == 0;
        final isLast = i == members.length - 1;
        rows.add(() => ContactListTile(
              profile: profile,
              isFirst: isFirst,
              isLast: isLast,
              onTap: () => _openEditProfile(profile),
              onLongPress: () => _handleToggleFavorite(profile),
            ));
      }
    }
    return rows;
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
      onImportAll: () => _importAllContacts(contacts),
    );
    if (!mounted || selected == null) return;

    await _openCreateFromContact(selected);
  }

  Future<void> _importAllContacts(List<ContactItem> contacts) async {
    final l10n = context.l10n;
    final existing = await _dbHelper.getAllProfiles();
    final existingPhones = <String>{
      for (final p in existing)
        if (p.normalizedPhone.isNotEmpty) p.normalizedPhone,
    };
    final existingHashes = <String>{
      for (final p in existing)
        if (p.profileHash.isNotEmpty) p.profileHash,
    };

    var importedCount = 0;
    for (final contact in contacts) {
      final name = contact.displayName.trim();
      if (name.isEmpty) continue;
      final normalizedPhone = ContactIndex.normalizePhone(contact.phoneNumber);
      final hashSeed = contact.phoneNumber.trim().isNotEmpty
          ? contact.phoneNumber.trim()
          : name;
      final hash = HashService.hashIdentifier(hashSeed);

      if ((normalizedPhone.isNotEmpty &&
              existingPhones.contains(normalizedPhone)) ||
          existingHashes.contains(hash)) {
        continue;
      }

      final profile = UserProfile.fromContact(
        contact: contact,
        profileHash: hash,
      );
      await _dbHelper.saveProfile(profile);
      if (normalizedPhone.isNotEmpty) {
        existingPhones.add(normalizedPhone);
      }
      existingHashes.add(hash);
      importedCount++;
    }

    await ExportService.instance.syncAll();
    await _loadProfiles();
    if (!mounted) return;

    proteinBar(
      context,
      l10n.importedContactsToast(importedCount),
      icon: LucideIcons.check,
    );
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
    // A search with zero hits still means the user has profiles.
    final hasProfiles = _profiles.isNotEmpty || hasSearchQuery;

    return Scaffold(
      appBar: _isSearching
          ? CustomAppBar.profiles(
              leading: IconButton(
                icon: const Icon(LucideIcons.arrowLeft, size: 22),
                onPressed: _stopSearch,
              ),
              titleWidget: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _loadProfiles,
                decoration: InputDecoration(
                  hintText: l10n.searchProfilesHint,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              actions: [
                if (hasSearchQuery)
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      _loadProfiles('');
                    },
                  ),
              ],
            )
          : CustomAppBar.profiles(
              actions: [
                IconButton(
                  onPressed: _openImportContact,
                  icon: const Icon(LucideIcons.bookUser, size: 22),
                  tooltip: l10n.importFromContactsTooltip,
                ),
                IconButton(
                  onPressed: _startSearch,
                  icon: const Icon(LucideIcons.search, size: 22),
                  tooltip: l10n.searchProfilesHint,
                ),
              ],
            ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _profiles.isEmpty
                ? (hasSearchQuery
                    ? const _ProfilesEmptyState.search()
                    : _ProfilesEmptyState.initial(
                        onImport: _openImportContact,
                        onCreateManual: _openCreateManual,
                      ))
                : Builder(
                    builder: (context) {
                      final rows = _buildRows();
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                        itemCount: rows.length,
                        itemBuilder: (context, index) => rows[index](),
                      );
                    },
                  ),
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
