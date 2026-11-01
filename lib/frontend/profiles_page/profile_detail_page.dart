import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data_models/contact_item.dart';
import '../../data_models/user_profile.dart';
import '../../services/contact_index.dart';
import '../../services/contact_service.dart';
import '../../services/database_helper.dart';
import '../../services/export_service.dart';
import '../../services/hash_service.dart';
import '../theme/app_colors.dart';
import '../util/custom_app_bar.dart';
import '../util/l10n_extensions.dart';
import '../util/proteinbar.dart';
import 'util/profile_form.dart';

class ProfileDetailPage extends StatefulWidget {
  final UserProfile initialProfile;
  final bool isNew;

  const ProfileDetailPage({
    super.key,
    required this.initialProfile,
    required this.isNew,
  });

  factory ProfileDetailPage.create({
    Key? key,
    ContactItem? contact,
  }) {
    if (contact != null) {
      final hash = HashService.hashIdentifier(contact.phoneNumber);
      return ProfileDetailPage(
        key: key,
        initialProfile: UserProfile.fromContact(
          contact: contact,
          profileHash: hash,
        ),
        isNew: true,
      );
    }

    final fallbackHash = HashService.hashIdentifier(
      DateTime.now().millisecondsSinceEpoch.toString(),
    );
    return ProfileDetailPage(
      key: key,
      initialProfile: UserProfile.empty(profileHash: fallbackHash),
      isNew: true,
    );
  }

  const ProfileDetailPage.edit({
    super.key,
    required UserProfile profile,
  })  : initialProfile = profile,
        isNew = false;

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final GlobalKey<ProfileFormState> _formKey = GlobalKey<ProfileFormState>();

  late UserProfile _profile;
  late bool _isEditing;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _profile = widget.initialProfile;
    _isEditing = widget.isNew;
  }

  Future<void> _launchAction(Uri uri) async {
    try {
      await launchUrl(uri);
    } catch (_) {
      if (mounted) {
        ProteinBar.fail(
          context,
          context.l10n.dialerCallFailed,
        );
      }
    }
  }

  void _handleCall() {
    final number = ContactIndex.sanitizeDialInput(_profile.phoneNumber);
    if (number.isEmpty) return;
    _launchAction(Uri(scheme: 'tel', path: number));
  }

  void _handleMessage() {
    final number = ContactIndex.sanitizeDialInput(_profile.phoneNumber);
    if (number.isEmpty) return;
    _launchAction(Uri(scheme: 'sms', path: number));
  }

  void _handleEmail() {
    final email = _profile.email?.trim() ?? '';
    if (email.isEmpty) return;
    _launchAction(Uri(scheme: 'mailto', path: email));
  }

  Future<void> _handleToggleFavorite() async {
    final id = _profile.id;
    if (id == null) return;
    final l10n = context.l10n;
    final nowFav = !_profile.isFavorite;
    await _dbHelper.toggleFavorite(id, nowFav);
    if (!mounted) return;
    setState(() {
      _profile = _profile.copyWith(isFavorite: nowFav);
      _hasChanges = true;
    });
    ProteinBar.success(
      context,
      nowFav ? l10n.favoriteAddedToastGeneric : l10n.favoriteRemovedToastGeneric,
      icon: nowFav ? LucideIcons.star : LucideIcons.starOff,
    );
  }

  Future<void> _handleSave(
    UserProfile updatedProfile, {
    bool addToDeviceContacts = false,
  }) async {
    final l10n = context.l10n;

    if (updatedProfile.name.trim().isEmpty) {
      ProteinBar.fail(
        context,
        l10n.enterNameError,
      );
      return;
    }

    final savedId = await _dbHelper.saveProfile(updatedProfile);
    final saved = await _dbHelper.getProfileById(savedId);
    final resolvedProfile = saved ?? updatedProfile;
    await ExportService.instance.syncProfile(resolvedProfile);

    bool phonebookSaved = false;
    if (addToDeviceContacts) {
      phonebookSaved = await ContactService.instance.insertDeviceContact(
        name: updatedProfile.name,
        phoneNumber: updatedProfile.phoneNumber,
        email: updatedProfile.email,
        notes: updatedProfile.notesToRemember,
      );
      if (!phonebookSaved && mounted) {
        ProteinBar.fail(
          context,
          l10n.phonebookSaveFailed,
        );
      }
    }

    if (!mounted) return;

    ProteinBar.success(
      context,
      (addToDeviceContacts && phonebookSaved)
          ? l10n.profileAndPhonebookSavedGeneric
          : l10n.profileSavedGeneric,
    );

    if (widget.isNew) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _profile = resolvedProfile;
        _isEditing = false;
        _hasChanges = true;
      });
    }
  }

  Future<void> _handleDelete() async {
    final id = _profile.id;
    if (id == null) return;
    final l10n = context.l10n;

    await _dbHelper.deleteProfile(id);
    await ExportService.instance.removeProfileChunk(_profile.profileHash);
    if (!mounted) return;

    ProteinBar.success(
      context,
      l10n.profileDeletedGeneric,
      icon: LucideIcons.trash2,
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_isEditing && !widget.isNew) {
          setState(() => _isEditing = false);
          return;
        }
        Navigator.of(context).pop(_hasChanges);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.chevronLeft, size: 24),
            onPressed: () {
              if (_isEditing && !widget.isNew) {
                setState(() => _isEditing = false);
              } else {
                Navigator.of(context).pop(_hasChanges);
              }
            },
          ),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              ProfileForm(
                key: _formKey,
                initialProfile: _profile,
                isNew: widget.isNew,
                isEditing: _isEditing,
                onSave: _handleSave,
                onCall: _handleCall,
                onMessage: _handleMessage,
                onEmail: _handleEmail,
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.navBarDark : AppColors.navBarLight,
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: isDark
                      ? AppColors.navBarBorderDark
                      : AppColors.navBarBorderLight,
                ),
              ),
              child: _isEditing
                  ? Row(
                      children: [
                        Expanded(
                          child: _BottomActionTile(
                            icon: LucideIcons.x,
                            label: l10n.cancelButton,
                            onTap: () {
                              if (widget.isNew) {
                                Navigator.of(context).pop(false);
                              } else {
                                setState(() => _isEditing = false);
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: _BottomActionTile(
                            icon: LucideIcons.check,
                            label: l10n.saveProfileButton,
                            iconColor: AppColors.success,
                            onTap: () => _formKey.currentState?.submit(),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _BottomActionTile(
                            icon: LucideIcons.star,
                            label: l10n.favoritesOnlyFilter,
                            iconColor: _profile.isFavorite
                                ? AppColors.gradientPeachStart
                                : null,
                            onTap: _handleToggleFavorite,
                          ),
                        ),
                        Expanded(
                          child: _BottomActionTile(
                            icon: LucideIcons.pencil,
                            label: l10n.editProfileButton,
                            onTap: () => setState(() => _isEditing = true),
                          ),
                        ),
                        if (_profile.id != null)
                          Expanded(
                            child: _BottomActionTile(
                              icon: LucideIcons.trash2,
                              label: l10n.deleteButton,
                              iconColor: AppColors.error,
                              onTap: _handleDelete,
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final VoidCallback onTap;

  const _BottomActionTile({
    required this.icon,
    required this.label,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: iconColor ?? defaultColor),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: defaultColor,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
