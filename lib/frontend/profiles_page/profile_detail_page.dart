import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data_models/contact_item.dart';
import '../../data_models/user_profile.dart';
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

  Future<void> _handleSave(
    UserProfile updatedProfile, {
    bool addToDeviceContacts = false,
  }) async {
    final l10n = context.l10n;

    if (updatedProfile.name.trim().isEmpty) {
      proteinBar(
        context,
        l10n.enterNameError,
        icon: LucideIcons.circleAlert,
      );
      return;
    }

    final savedId = await _dbHelper.saveProfile(updatedProfile);
    final saved = await _dbHelper.getProfileById(savedId);
    await ExportService.instance.syncProfile(saved ?? updatedProfile);

    bool phonebookSaved = false;
    if (addToDeviceContacts) {
      phonebookSaved = await ContactService.instance.insertDeviceContact(
        name: updatedProfile.name,
        phoneNumber: updatedProfile.phoneNumber,
        email: updatedProfile.email,
        notes: updatedProfile.notesToRemember,
      );
      if (!phonebookSaved && mounted) {
        proteinBar(
          context,
          l10n.phonebookSaveFailed,
          icon: LucideIcons.circleAlert,
        );
      }
    }

    if (!mounted) return;

    proteinBar(
      context,
      (addToDeviceContacts && phonebookSaved)
          ? l10n.profileAndPhonebookSaved(updatedProfile.name)
          : l10n.profileSaved(updatedProfile.name),
      icon: LucideIcons.check,
    );
    Navigator.of(context).pop(true);
  }

  Future<void> _handleDelete() async {
    final id = widget.initialProfile.id;
    if (id == null) return;
    final l10n = context.l10n;

    await _dbHelper.deleteProfile(id);
    await ExportService.instance.removeProfileChunk(
      widget.initialProfile.profileHash,
    );
    if (!mounted) return;

    proteinBar(
      context,
      l10n.profileDeleted(widget.initialProfile.name),
      icon: LucideIcons.trash2,
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final headerTitle = widget.isNew
        ? l10n.newProfileTitle
        : (widget.initialProfile.name.trim().isNotEmpty
            ? widget.initialProfile.name
            : l10n.unnamedProfile);

    return Scaffold(
      appBar: CustomAppBar.detail(
        title: headerTitle,
        actions: [
          if (!widget.isNew && widget.initialProfile.id != null)
            IconButton(
              onPressed: _handleDelete,
              icon: const Icon(
                LucideIcons.trash2,
                size: 20,
                color: AppColors.error,
              ),
              tooltip: l10n.deleteProfileTooltip,
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            ProfileForm(
              initialProfile: widget.initialProfile,
              isNew: widget.isNew,
              onSave: _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}
