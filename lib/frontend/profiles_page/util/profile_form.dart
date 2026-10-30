import 'package:confidants/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data_models/custom_field.dart';
import '../../../data_models/user_profile.dart';
import '../../../services/hash_service.dart';
import '../../settings_page/util/settings_toggle_tile.dart';
import '../../theme/app_colors.dart';
import '../../util/avatar_icon_helper.dart';
import '../../util/l10n_extensions.dart';
import 'custom_field_editor.dart';

typedef ProfileSaveCallback = void Function(
  UserProfile profile, {
  bool addToDeviceContacts,
});

class ProfileForm extends StatefulWidget {
  final UserProfile initialProfile;
  final bool isNew;
  final ProfileSaveCallback onSave;

  const ProfileForm({
    super.key,
    required this.initialProfile,
    this.isNew = false,
    required this.onSave,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
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
    final p = widget.initialProfile;
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

  void _submit() {
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

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor =
        isDark ? AppColors.accentHighlight : AppColors.primaryDarkBlue;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: secondaryTextColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final avatarBg =
        isDark ? AppColors.secondaryDarkBlue : AppColors.primaryDarkBlue;
    final favoriteStarColor =
        isDark ? AppColors.accentHighlight : AppColors.primaryDarkBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // SECTION 1: Basic Information
        _buildSectionHeader(
          icon: LucideIcons.userCheck,
          title: l10n.sectionBasicInfo,
          subtitle: l10n.sectionBasicInfoSubtitle,
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar icon + Favorite toggle row
                Row(
                  children: [
                    InkWell(
                      onTap: _showAvatarPicker,
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: avatarBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              AvatarIconHelper.resolve(_avatarIcon),
                              size: 28,
                              color: AppColors.surfaceLight,
                            ),
                          ),
                          Positioned(
                            right: -4,
                            bottom: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.surfaceDark
                                    : AppColors.surfaceLight,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                ),
                              ),
                              child: Icon(
                                LucideIcons.pencil,
                                size: 11,
                                color: isDark
                                    ? AppColors.accentHighlight
                                    : AppColors.primaryDarkBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.favoriteLabel,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.favoriteSubtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isFavorite ? LucideIcons.star : LucideIcons.starOff,
                        size: 24,
                        color: _isFavorite
                            ? favoriteStarColor
                            : secondaryTextColor,
                      ),
                      tooltip: l10n.favoriteTooltip,
                      onPressed: () => setState(() => _isFavorite = !_isFavorite),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ProfileField.name(controller: _nameController),
                _ProfileField.nickname(controller: _nicknameController),
              ],
            ),
          ),
        ),

        // SECTION 2: Contact Details
        _buildSectionHeader(
          icon: LucideIcons.contact,
          title: l10n.sectionContactDetails,
          subtitle: l10n.sectionContactDetailsSubtitle,
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _ProfileField.phone(controller: _phoneController),
                _ProfileField.email(controller: _emailController),
                Material(
                  color: isDark
                      ? AppColors.backgroundDark
                      : AppColors.backgroundLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: ListTile(
                    onTap: _pickBirthday,
                    dense: true,
                    leading: Icon(
                      LucideIcons.cake,
                      size: 20,
                      color: isDark
                          ? AppColors.accentHighlight
                          : AppColors.primaryDarkBlue,
                    ),
                    title: Text(
                      _birthday ?? l10n.selectBirthday,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            _birthday != null ? FontWeight.w600 : FontWeight.w400,
                        color: _birthday != null ? null : secondaryTextColor,
                      ),
                    ),
                    subtitle: Text(
                      l10n.birthdayStoredHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: secondaryTextColor,
                        fontSize: 11,
                      ),
                    ),
                    trailing: _birthday != null
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 18),
                            onPressed: () => setState(() => _birthday = null),
                          )
                        : const Icon(LucideIcons.calendar, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),

        // SECTION 3: Personal Context & Reminders
        _buildSectionHeader(
          icon: LucideIcons.sparkles,
          title: l10n.sectionPersonalContext,
          subtitle: l10n.sectionPersonalContextSubtitle,
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _ProfileField.notes(controller: _notesController),
                _ProfileField.likes(controller: _likesController),
                _ProfileField.dislikes(controller: _dislikesController),
                _ProfileField.hobbies(controller: _hobbiesController),
              ],
            ),
          ),
        ),

        // SECTION 4: Custom Attributes
        _buildSectionHeader(
          icon: LucideIcons.layers,
          title: l10n.sectionCustomAttributes,
          subtitle: l10n.sectionCustomAttributesSubtitle,
        ),
        CustomFieldEditor(
          fields: _customFields,
          onChanged: (updated) => setState(() => _customFields = updated),
        ),

        if (widget.isNew || widget.initialProfile.id == null) ...[
          const SizedBox(height: 6),
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: CheckboxListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              secondary: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.secondaryDarkBlue
                      : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(10),
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
        ],

        const SizedBox(height: 6),
        SettingsToggleTile.training(
          isEnabled: _isTrainingEnabled,
          onChanged: (val) => setState(() => _isTrainingEnabled = val),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: primaryBtnBg,
            foregroundColor: AppColors.surfaceLight,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          icon: const Icon(LucideIcons.save, size: 18),
          label: Text(l10n.saveProfileButton),
        ),
      ],
    );
  }
}

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final L10nText labelOf;
  final L10nText hintOf;
  final TextInputType keyboardType;
  final int maxLines;

  const _ProfileField.name({
    required this.controller,
  })  : icon = LucideIcons.user,
        labelOf = _nameLabel,
        hintOf = _nameHint,
        keyboardType = TextInputType.name,
        maxLines = 1;

  const _ProfileField.nickname({
    required this.controller,
  })  : icon = LucideIcons.tag,
        labelOf = _nicknameLabel,
        hintOf = _nicknameHint,
        keyboardType = TextInputType.text,
        maxLines = 1;

  const _ProfileField.phone({
    required this.controller,
  })  : icon = LucideIcons.phone,
        labelOf = _phoneLabel,
        hintOf = _phoneHint,
        keyboardType = TextInputType.phone,
        maxLines = 1;

  const _ProfileField.email({
    required this.controller,
  })  : icon = LucideIcons.mail,
        labelOf = _emailLabel,
        hintOf = _emailHint,
        keyboardType = TextInputType.emailAddress,
        maxLines = 1;

  const _ProfileField.notes({
    required this.controller,
  })  : icon = LucideIcons.notebookPen,
        labelOf = _notesLabel,
        hintOf = _notesHint,
        keyboardType = TextInputType.multiline,
        maxLines = 3;

  const _ProfileField.likes({
    required this.controller,
  })  : icon = LucideIcons.thumbsUp,
        labelOf = _likesLabel,
        hintOf = _likesHint,
        keyboardType = TextInputType.text,
        maxLines = 1;

  const _ProfileField.dislikes({
    required this.controller,
  })  : icon = LucideIcons.thumbsDown,
        labelOf = _dislikesLabel,
        hintOf = _dislikesHint,
        keyboardType = TextInputType.text,
        maxLines = 1;

  const _ProfileField.hobbies({
    required this.controller,
  })  : icon = LucideIcons.compass,
        labelOf = _hobbiesLabel,
        hintOf = _hobbiesHint,
        keyboardType = TextInputType.text,
        maxLines = 1;

  static String _nameLabel(AppLocalizations l10n) => l10n.fieldFullName;
  static String _nameHint(AppLocalizations l10n) => l10n.hintFullName;
  static String _nicknameLabel(AppLocalizations l10n) => l10n.fieldNickname;
  static String _nicknameHint(AppLocalizations l10n) => l10n.hintNickname;
  static String _phoneLabel(AppLocalizations l10n) => l10n.fieldPhone;
  static String _phoneHint(AppLocalizations l10n) => l10n.hintPhone;
  static String _emailLabel(AppLocalizations l10n) => l10n.fieldEmail;
  static String _emailHint(AppLocalizations l10n) => l10n.hintEmail;
  static String _notesLabel(AppLocalizations l10n) => l10n.fieldNotes;
  static String _notesHint(AppLocalizations l10n) => l10n.hintNotes;
  static String _likesLabel(AppLocalizations l10n) => l10n.fieldLikes;
  static String _likesHint(AppLocalizations l10n) => l10n.hintLikes;
  static String _dislikesLabel(AppLocalizations l10n) => l10n.fieldDislikes;
  static String _dislikesHint(AppLocalizations l10n) => l10n.hintDislikes;
  static String _hobbiesLabel(AppLocalizations l10n) => l10n.fieldHobbies;
  static String _hobbiesHint(AppLocalizations l10n) => l10n.hintHobbies;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelOf(l10n),
          hintText: hintOf(l10n),
          prefixIcon: Icon(icon, size: 18),
        ),
      ),
    );
  }
}
