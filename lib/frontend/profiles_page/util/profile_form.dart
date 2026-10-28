import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:confidants/l10n/app_localizations.dart';
import '../../../data_models/custom_field.dart';
import '../../../data_models/user_profile.dart';
import '../../../services/hash_service.dart';
import '../../settings_page/util/settings_toggle_tile.dart';
import '../../theme/app_colors.dart';
import '../../util/l10n_extensions.dart';
import 'custom_field_editor.dart';

class ProfileForm extends StatefulWidget {
  final UserProfile initialProfile;
  final ValueChanged<UserProfile> onSave;

  const ProfileForm({
    super.key,
    required this.initialProfile,
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

  late String? _birthday;
  late bool _isTrainingEnabled;
  late List<CustomField> _customFields;

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

    // Built directly (not via copyWith) so cleared optional fields really become null.
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
      isTrainingEnabled: _isTrainingEnabled,
      createdAt: initial.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      customFields: cleanedFields,
    );

    widget.onSave(updated);
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryBtnBg =
        isDark ? AppColors.secondaryDarkBlue : AppColors.primaryDarkBlue;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProfileField.name(controller: _nameController),
        _ProfileField.nickname(controller: _nicknameController),
        _ProfileField.phone(controller: _phoneController),
        _ProfileField.email(controller: _emailController),
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: _pickBirthday,
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
                fontWeight: _birthday != null ? FontWeight.w600 : FontWeight.w400,
                color: _birthday != null ? null : secondaryTextColor,
              ),
            ),
            subtitle: Text(
              l10n.birthdayStoredHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: secondaryTextColor,
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
        _ProfileField.notes(controller: _notesController),
        _ProfileField.likes(controller: _likesController),
        _ProfileField.dislikes(controller: _dislikesController),
        _ProfileField.hobbies(controller: _hobbiesController),
        CustomFieldEditor(
          fields: _customFields,
          onChanged: (updated) => setState(() => _customFields = updated),
        ),
        SettingsToggleTile.training(
          isEnabled: _isTrainingEnabled,
          onChanged: (val) => setState(() => _isTrainingEnabled = val),
        ),
        const SizedBox(height: 12),
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
        maxLines = 4;

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
