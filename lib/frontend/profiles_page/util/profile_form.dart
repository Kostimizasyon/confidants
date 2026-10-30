import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data_models/custom_field.dart';
import '../../../data_models/user_profile.dart';
import '../../../services/hash_service.dart';
import '../../settings_page/util/settings_toggle_tile.dart';
import '../../theme/app_colors.dart';
import '../../util/avatar_icon_helper.dart';
import '../../util/contact_avatar.dart';
import '../../util/l10n_extensions.dart';
import 'custom_field_editor.dart';

typedef ProfileSaveCallback = void Function(
  UserProfile profile, {
  bool addToDeviceContacts,
});

class ProfileForm extends StatefulWidget {
  final UserProfile initialProfile;
  final bool isNew;
  final bool isEditing;
  final ProfileSaveCallback onSave;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;
  final VoidCallback? onEmail;

  const ProfileForm({
    super.key,
    required this.initialProfile,
    this.isNew = false,
    this.isEditing = true,
    required this.onSave,
    this.onCall,
    this.onMessage,
    this.onEmail,
  });

  @override
  State<ProfileForm> createState() => ProfileFormState();
}

class ProfileFormState extends State<ProfileForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _notesController;
  late final TextEditingController _likesController;
  late final TextEditingController _dislikesController;
  late final TextEditingController _hobbiesController;

  late String _avatarIcon;
  late bool _isFavorite;
  late String? _birthday;
  late bool _isTrainingEnabled;
  late List<CustomField> _customFields;
  bool _addToDeviceContacts = false;

  @override
  void initState() {
    super.initState();
    _syncFromProfile(widget.initialProfile);
  }

  @override
  void didUpdateWidget(covariant ProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialProfile != widget.initialProfile && !widget.isEditing) {
      _nameController.text = widget.initialProfile.name;
      _nicknameController.text = widget.initialProfile.nickname ?? '';
      _phoneController.text = widget.initialProfile.phoneNumber;
      _emailController.text = widget.initialProfile.email ?? '';
      _notesController.text = widget.initialProfile.notesToRemember;
      _likesController.text = widget.initialProfile.likes.join(', ');
      _dislikesController.text = widget.initialProfile.dislikes.join(', ');
      _hobbiesController.text = widget.initialProfile.hobbies.join(', ');
      _avatarIcon = widget.initialProfile.avatarIcon;
      _isFavorite = widget.initialProfile.isFavorite;
      _birthday = widget.initialProfile.birthday;
      _isTrainingEnabled = widget.initialProfile.isTrainingEnabled;
      _customFields = List<CustomField>.from(widget.initialProfile.customFields);
    }
  }

  void _syncFromProfile(UserProfile p) {
    _nameController = TextEditingController(text: p.name);
    _nicknameController = TextEditingController(text: p.nickname ?? '');
    _phoneController = TextEditingController(text: p.phoneNumber);
    _emailController = TextEditingController(text: p.email ?? '');
    _notesController = TextEditingController(text: p.notesToRemember);
    _likesController = TextEditingController(text: p.likes.join(', '));
    _dislikesController = TextEditingController(text: p.dislikes.join(', '));
    _hobbiesController = TextEditingController(text: p.hobbies.join(', '));

    _avatarIcon = p.avatarIcon;
    _isFavorite = p.isFavorite;
    _birthday = p.birthday;
    _isTrainingEnabled = p.isTrainingEnabled;
    _customFields = List<CustomField>.from(p.customFields);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    _likesController.dispose();
    _dislikesController.dispose();
    _hobbiesController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    if (!widget.isEditing) return;
    final now = DateTime.now();
    final initialDate = _birthday != null
        ? (DateTime.tryParse(_birthday!) ?? DateTime(now.year - 25, 1, 1))
        : DateTime(now.year - 25, 1, 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1920),
      lastDate: now,
    );

    if (picked != null && mounted) {
      final isoDate =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() => _birthday = isoDate);
    }
  }

  void _showAvatarPicker() {
    if (!widget.isEditing) return;
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final selectedBg =
        isDark ? AppColors.secondaryDarkBlue : AppColors.primaryDarkBlue;
    final unselectedBg =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.chooseAvatarTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: AvatarIconHelper.availableKeys.length,
                  itemBuilder: (context, index) {
                    final key = AvatarIconHelper.availableKeys[index];
                    final isSelected = key == _avatarIcon;
                    final iconData = AvatarIconHelper.resolve(key);

                    return InkWell(
                      onTap: () {
                        setState(() => _avatarIcon = key);
                        Navigator.of(bottomSheetContext).pop();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? selectedBg : unselectedBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? (isDark
                                    ? AppColors.accentHighlight
                                    : AppColors.primaryDarkBlue)
                                : (isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          iconData,
                          size: 22,
                          color: isSelected
                              ? AppColors.surfaceLight
                              : (isDark
                                  ? AppColors.accentHighlight
                                  : AppColors.primaryDarkBlue),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void submit() {
    final initial = widget.initialProfile;
    final rawPhone = _phoneController.text.trim();
    final rawName = _nameController.text.trim();
    final hashSeed = rawPhone.isNotEmpty
        ? rawPhone
        : (rawName.isNotEmpty
            ? rawName
            : DateTime.now().millisecondsSinceEpoch.toString());

    final computedHash = initial.id != null
        ? initial.profileHash
        : HashService.hashIdentifier(hashSeed);

    final cleanedFields = _customFields
        .where((f) => f.fieldKey.trim().isNotEmpty)
        .toList();

    final updated = UserProfile(
      id: initial.id,
      profileHash: computedHash,
      name: rawName,
      nickname: _emptyToNull(_nicknameController.text),
      phoneNumber: rawPhone,
      email: _emptyToNull(_emailController.text),
      birthday: _birthday,
      notesToRemember: _notesController.text.trim(),
      likes: _splitCommaList(_likesController.text),
      dislikes: _splitCommaList(_dislikesController.text),
      hobbies: _splitCommaList(_hobbiesController.text),
      avatarIcon: _avatarIcon,
      isFavorite: _isFavorite,
      isTrainingEnabled: _isTrainingEnabled,
      createdAt: initial.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      customFields: cleanedFields,
    );

    widget.onSave(
      updated,
      addToDeviceContacts: _addToDeviceContacts,
    );
  }

  String? _emptyToNull(String raw) {
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  List<String> _splitCommaList(String raw) {
    if (raw.trim().isEmpty) return const [];
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Widget _buildIsland({
    required bool isDark,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
    double radius = 26,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.8,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }

  Widget _buildHeroActionCircle({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String tooltip,
    required VoidCallback? onTap,
  }) {
    final circleBg = isDark ? AppColors.navBarDark : AppColors.navBarLight;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: circleBg,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, size: 22, color: iconColor),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableIslandRow({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color iconBadgeColor,
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final val = controller.text.trim();

    if (!widget.isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    val.isNotEmpty ? val : '—',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: val.isNotEmpty ? null : secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBadgeColor.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: iconBadgeColor),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 18, color: iconBadgeColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryBtnBg =
        isDark ? AppColors.secondaryDarkBlue : AppColors.primaryDarkBlue;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final previewProfile = widget.initialProfile.copyWith(
      name: _nameController.text,
      avatarIcon: _avatarIcon,
      isFavorite: _isFavorite,
    );

    final displayName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : l10n.unnamedProfile;
    final displayNickname = _nicknameController.text.trim();
    final displayPhone = _phoneController.text.trim().isNotEmpty
        ? _phoneController.text.trim()
        : l10n.noPhoneNumber;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ISLAND 1: Hero Island (Name, Nickname, Phone, Avatar & Quick Actions)
        _buildIsland(
          isDark: isDark,
          radius: 28,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: widget.isEditing
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _nameController,
                                keyboardType: TextInputType.name,
                                onChanged: (_) => setState(() {}),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: InputDecoration(
                                  labelText: l10n.fieldFullName,
                                  hintText: l10n.hintFullName,
                                  prefixIcon: const Icon(LucideIcons.user, size: 18),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _nicknameController,
                                decoration: InputDecoration(
                                  labelText: l10n.fieldNickname,
                                  hintText: l10n.hintNickname,
                                  prefixIcon: const Icon(LucideIcons.tag, size: 18),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  labelText: l10n.fieldPhone,
                                  hintText: l10n.hintPhone,
                                  prefixIcon: const Icon(LucideIcons.phone, size: 18),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (displayNickname.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  displayNickname,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: secondaryTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              Text(
                                displayPhone,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: widget.isEditing ? _showAvatarPicker : null,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ContactAvatar(profile: previewProfile, size: 64),
                        if (widget.isEditing)
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.navPillDark
                                    : AppColors.navPillLight,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                ),
                              ),
                              child: Icon(
                                LucideIcons.pencil,
                                size: 12,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!widget.isEditing) ...[
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildHeroActionCircle(
                      isDark: isDark,
                      icon: LucideIcons.phone,
                      iconColor: AppColors.success,
                      tooltip: l10n.dialerCallTooltip,
                      onTap: widget.onCall,
                    ),
                    _buildHeroActionCircle(
                      isDark: isDark,
                      icon: LucideIcons.messageSquare,
                      iconColor: AppColors.avatarGradientEnd,
                      tooltip: l10n.messageTooltip,
                      onTap: widget.onMessage,
                    ),
                    _buildHeroActionCircle(
                      isDark: isDark,
                      icon: LucideIcons.mail,
                      iconColor: AppColors.avatarGradientStart,
                      tooltip: l10n.fieldEmail,
                      onTap: widget.onEmail,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // ISLAND 2: Contact Details (Email & Birthday)
        _buildIsland(
          isDark: isDark,
          child: Column(
            children: [
              _buildEditableIslandRow(
                context: context,
                isDark: isDark,
                icon: LucideIcons.mail,
                iconBadgeColor: AppColors.avatarGradientEnd,
                label: l10n.fieldEmail,
                hint: l10n.hintEmail,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              Divider(
                height: 16,
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              InkWell(
                onTap: widget.isEditing ? _pickBirthday : null,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.selectBirthday,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: secondaryTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _birthday ?? '—',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: _birthday != null ? null : secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.isEditing && _birthday != null)
                        IconButton(
                          icon: const Icon(LucideIcons.x, size: 18),
                          onPressed: () => setState(() => _birthday = null),
                        ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.gradientPeachStart.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.cake,
                          size: 18,
                          color: AppColors.gradientPeachStart,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ISLAND 3: Personal Context (Notes, Likes, Dislikes, Hobbies)
        _buildIsland(
          isDark: isDark,
          child: Column(
            children: [
              _buildEditableIslandRow(
                context: context,
                isDark: isDark,
                icon: LucideIcons.notebookPen,
                iconBadgeColor: AppColors.accentHighlight,
                label: l10n.fieldNotes,
                hint: l10n.hintNotes,
                controller: _notesController,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
              ),
              Divider(
                height: 16,
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              _buildEditableIslandRow(
                context: context,
                isDark: isDark,
                icon: LucideIcons.thumbsUp,
                iconBadgeColor: AppColors.success,
                label: l10n.fieldLikes,
                hint: l10n.hintLikes,
                controller: _likesController,
              ),
              Divider(
                height: 16,
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              _buildEditableIslandRow(
                context: context,
                isDark: isDark,
                icon: LucideIcons.thumbsDown,
                iconBadgeColor: AppColors.error,
                label: l10n.fieldDislikes,
                hint: l10n.hintDislikes,
                controller: _dislikesController,
              ),
              Divider(
                height: 16,
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              _buildEditableIslandRow(
                context: context,
                isDark: isDark,
                icon: LucideIcons.compass,
                iconBadgeColor: AppColors.gradientSkyEnd,
                label: l10n.fieldHobbies,
                hint: l10n.hintHobbies,
                controller: _hobbiesController,
              ),
            ],
          ),
        ),

        // ISLAND 4: Custom Attributes
        if (widget.isEditing)
          _buildIsland(
            isDark: isDark,
            padding: const EdgeInsets.all(14),
            child: CustomFieldEditor(
              fields: _customFields,
              onChanged: (updated) => setState(() => _customFields = updated),
            ),
          )
        else if (_customFields.isNotEmpty)
          ..._customFields.map(
            (field) => _buildIsland(
              isDark: isDark,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          field.fieldKey,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          field.fieldValue,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.gradientLavenderEnd.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.sparkles,
                      size: 18,
                      color: AppColors.gradientLavenderEnd,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ISLAND 5: Phonebook Sync (New Confidants) & Local AI Knowledge Base
        if (widget.isEditing && (widget.isNew || widget.initialProfile.id == null))
          _buildIsland(
            isDark: isDark,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: CheckboxListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              secondary: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.secondaryDarkBlue
                      : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.bookUser,
                  size: 20,
                  color: isDark
                      ? AppColors.accentHighlight
                      : AppColors.primaryDarkBlue,
                ),
              ),
              title: Text(
                l10n.addToPhonebookTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.addToPhonebookSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
              ),
              value: _addToDeviceContacts,
              activeColor:
                  isDark ? AppColors.accentBlue : AppColors.primaryDarkBlue,
              checkColor: AppColors.surfaceLight,
              checkboxShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              controlAffinity: ListTileControlAffinity.trailing,
              onChanged: (val) =>
                  setState(() => _addToDeviceContacts = val ?? false),
            ),
          ),

        SettingsToggleTile.training(
          isEnabled: _isTrainingEnabled,
          onChanged: (val) {
            if (widget.isEditing) {
              setState(() => _isTrainingEnabled = val);
            }
          },
        ),

        if (widget.isEditing) ...[
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: submit,
            style: FilledButton.styleFrom(
              backgroundColor: primaryBtnBg,
              foregroundColor: AppColors.surfaceLight,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            icon: const Icon(LucideIcons.save, size: 18),
            label: Text(l10n.saveProfileButton),
          ),
        ],
      ],
    );
  }
}
