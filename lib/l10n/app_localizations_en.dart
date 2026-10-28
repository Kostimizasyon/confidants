// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Confidants';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfiles => 'Profiles';

  @override
  String get navSettings => 'Settings';

  @override
  String get chatTitle => 'Confidants AI';

  @override
  String get chatSubtitle => 'Offline personal context assistant';

  @override
  String get chatPlaceholderTitle => 'Local AI Chat Interface';

  @override
  String get chatPlaceholderMessage =>
      'Ask anything about your saved profiles. Context chunks are loaded locally on your device.';

  @override
  String get profilesTitle => 'Profiles';

  @override
  String get profilesSubtitle => 'Contacts & personal knowledge base';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Security, appearance & AI';

  @override
  String get detailSubtitle => 'Profile details & custom attributes';

  @override
  String get newProfileTitle => 'New Confidant Profile';

  @override
  String get unnamedProfile => 'Unnamed Profile';

  @override
  String get authVaultLockedTitle => 'Confidants Vault Locked';

  @override
  String get authVaultLockedMessage =>
      'Verify your identity with biometrics or device credentials to continue.';

  @override
  String get authVaultFailedMessage =>
      'Authentication was canceled or did not succeed. Verify your identity to access offline profiles.';

  @override
  String get authUnlockButton => 'Unlock Confidants';

  @override
  String get authUnlockReason => 'Authenticate to unlock Confidants';

  @override
  String get authEnableReason =>
      'Confirm your identity to enable biometric launch lock';

  @override
  String get biometricsUnavailable =>
      'Biometric authentication is not available on this device.';

  @override
  String get darkModeTitle => 'Dark Mode';

  @override
  String get darkModeSubtitleOn => 'Dark blue & carbon theme active';

  @override
  String get darkModeSubtitleOff => 'High-contrast light theme active';

  @override
  String get biometricLockTitle => 'Biometric Launch Lock';

  @override
  String get biometricLockSubtitle =>
      'Require fingerprint or device authentication on startup';

  @override
  String get trainingTitle => 'Include in AI Knowledge Base';

  @override
  String get trainingSubtitle =>
      'Export this profile to local mini-LLM context chunks';

  @override
  String get aiOptInTitle => 'Enable Local AI Assistant';

  @override
  String get aiOptInSubtitle =>
      'Opt in to query your profiles with an on-device mini-LLM';

  @override
  String get aiModelSectionTitle => 'AI Model Configuration';

  @override
  String get aiModelDropdownLabel => 'Select On-Device Model';

  @override
  String get aiModelSmolTitle => 'SmolLM2 360M Instruct';

  @override
  String get aiModelSmolSpecs => 'Storage: ~250 MB • RAM: ~450 MB';

  @override
  String get aiModelSmolWarning =>
      'Featherlight footprint. Runs smoothly on almost any device with minimal battery impact, best for simple English keyword lookups.';

  @override
  String get aiModelQwenHalfTitle => 'Qwen 2.5 0.5B Instruct (Default)';

  @override
  String get aiModelQwenHalfSpecs => 'Storage: ~350 MB • RAM: ~600 MB';

  @override
  String get aiModelQwenHalfWarning =>
      'Low storage and memory usage. Fast response speed on most phones and handles basic English context recall reliably.';

  @override
  String get aiModelLlamaOneTitle => 'Llama 3.2 1B Instruct';

  @override
  String get aiModelLlamaOneSpecs => 'Storage: ~750 MB • RAM: ~1.3 GB';

  @override
  String get aiModelLlamaOneWarning =>
      'Moderate download and RAM usage. Stronger conversational English reasoning, but may warm up older devices.';

  @override
  String get aiModelQwenOneHalfTitle => 'Qwen 2.5 1.5B Instruct';

  @override
  String get aiModelQwenOneHalfSpecs => 'Storage: ~1.0 GB • RAM: ~1.8 GB';

  @override
  String get aiModelQwenOneHalfWarning =>
      'Requires ~1 GB storage and nearly 2 GB free RAM. Better multi-profile reasoning, recommended for mid-to-high-tier devices.';

  @override
  String get aiModelLlamaThreeTitle => 'Llama 3.2 3B Instruct';

  @override
  String get aiModelLlamaThreeSpecs => 'Storage: ~2.0 GB • RAM: ~3.2 GB';

  @override
  String get aiModelLlamaThreeWarning =>
      'Heavy storage and RAM warning: Needs 2 GB disk space and over 3 GB free RAM. May cause slowdowns or out-of-memory crashes on budget phones.';

  @override
  String get aiModelCustomTitle => 'Custom Local Model (.gguf)';

  @override
  String get aiModelCustomSpecs => 'Storage & RAM: Depends on your .gguf file';

  @override
  String get aiModelCustomWarning =>
      'Warning: Large quantizations (>2 GB) can exceed mobile RAM limits and crash the app. Prefer Q4_K_M models between 0.5B and 1.5B.';

  @override
  String get aiModelCustomSubtitleUnset =>
      'No custom .gguf file path selected yet';

  @override
  String get aiModelCustomChangeButton => 'Choose .gguf Path';

  @override
  String get aiModelCustomDialogTitle => 'Set Custom Model Path';

  @override
  String get aiModelCustomPathLabel => 'Local .gguf File Path';

  @override
  String get aiModelCustomPathHint => '/storage/emulated/0/Download/model.gguf';

  @override
  String get aiModelCustomSaveButton => 'Use Model';

  @override
  String get aiModelCustomCancelButton => 'Cancel';

  @override
  String aiModelSwitchedToast(String modelName) {
    return 'Active model set to $modelName.';
  }

  @override
  String get aiModelCustomInvalidToast =>
      'Please enter a valid .gguf file path.';

  @override
  String get chatOptInRequiredTitle => 'Local AI is Disabled';

  @override
  String get chatOptInRequiredSubtitle =>
      'Opt in to Local AI in Settings or tap below to enable on-device profile querying.';

  @override
  String get chatOptInButton => 'Enable Local AI';

  @override
  String get chatEmptyTitle => 'Ask About Your Confidants';

  @override
  String chatEmptySubtitle(String modelName, int chunkCount) {
    String _temp0 = intl.Intl.pluralLogic(
      chunkCount,
      locale: localeName,
      other: '$chunkCount profile chunks in memory',
      one: '1 profile chunk in memory',
      zero: 'No profile chunks indexed yet',
    );
    return 'Active model: $modelName • $_temp0';
  }

  @override
  String get chatInputHint => 'Ask about birthdays, coffee orders, hobbies...';

  @override
  String get chatClearTooltip => 'Clear Conversation';

  @override
  String get chatClearedToast => 'Conversation cleared.';

  @override
  String get chatGeneratingStatus => 'Thinking...';

  @override
  String get chatErrorResponse =>
      'Unable to generate a response from local AI context.';

  @override
  String get chatNoContextResponse =>
      'No training-enabled profile chunks are indexed yet. Add a profile in the Profiles tab first.';

  @override
  String chatMockPrefix(String modelName, int chunkCount, String summary) {
    return '[$modelName • $chunkCount chunks in context]\n$summary';
  }

  @override
  String get chatNoMatchSummary =>
      'I checked your exported profile context chunks, but couldn\'t find a direct match for that query. Try asking by a person\'s name, nickname, birthday, likes, or custom attributes.';

  @override
  String get searchProfilesHint =>
      'Search profiles by name, phone, or notes...';

  @override
  String get importFromContactsTooltip => 'Import from Contacts';

  @override
  String get newProfileTooltip => 'New Profile';

  @override
  String get addProfileButton => 'Add Profile';

  @override
  String get noContactsFound => 'No contacts found or permission denied.';

  @override
  String get emptyInitialTitle => 'No Confidant Profiles Yet';

  @override
  String get emptyInitialSubtitle =>
      'Import a contact from your address book or create a rich personal profile manually.';

  @override
  String get importContactButton => 'Import Contact';

  @override
  String get createManuallyButton => 'Create Manually';

  @override
  String get emptySearchTitle => 'No Matching Profiles';

  @override
  String get emptySearchSubtitle =>
      'Try adjusting your search keywords or phone number filter.';

  @override
  String get importDeviceContactTitle => 'Import Device Contact';

  @override
  String get searchContactsHint => 'Search contacts by name or phone...';

  @override
  String get noMatchingContacts => 'No matching contacts found.';

  @override
  String get enterNameError => 'Please enter a name for this profile.';

  @override
  String profileSaved(String name) {
    return 'Profile saved for $name.';
  }

  @override
  String profileDeleted(String name) {
    return 'Deleted $name.';
  }

  @override
  String get deleteProfileTooltip => 'Delete Profile';

  @override
  String get noPhoneNumber => 'No phone number';

  @override
  String sha256Label(String hash) {
    return 'SHA-256: $hash';
  }

  @override
  String customAttributesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count custom attributes',
      one: '1 custom attribute',
      zero: 'No custom attributes',
    );
    return '$_temp0';
  }

  @override
  String get fieldFullName => 'Full Name';

  @override
  String get hintFullName => 'Enter contact name';

  @override
  String get fieldNickname => 'Nickname (Optional)';

  @override
  String get hintNickname => 'What do you call them?';

  @override
  String get fieldPhone => 'Phone Number';

  @override
  String get hintPhone => '+1 555 010 9999';

  @override
  String get fieldEmail => 'Email Address (Optional)';

  @override
  String get hintEmail => 'person@example.com';

  @override
  String get fieldNotes => 'Notes to Remember';

  @override
  String get hintNotes => 'Key personal context, stories, and reminders...';

  @override
  String get fieldLikes => 'Likes (comma-separated)';

  @override
  String get hintLikes => 'Matcha, jazz, sci-fi books';

  @override
  String get fieldDislikes => 'Dislikes (comma-separated)';

  @override
  String get hintDislikes => 'Crowded places, cilantro';

  @override
  String get fieldHobbies => 'Hobbies & Interests (comma-separated)';

  @override
  String get hintHobbies => 'Bouldering, analog photography, chess';

  @override
  String get selectBirthday => 'Select Birthday';

  @override
  String get birthdayStoredHint => 'ISO 8601 date stored locally';

  @override
  String get saveProfileButton => 'Save Profile';

  @override
  String get customAttributesTitle => 'Custom Attributes';

  @override
  String get addRowButton => 'Add Row';

  @override
  String get customAttributesEmptyHint =>
      'Add dynamic key-value pairs (e.g., Favorite Coffee, Allergies, Pet Name).';

  @override
  String get attributeLabel => 'Attribute';

  @override
  String get attributeHint => 'e.g. Coffee';

  @override
  String get valueLabel => 'Value';

  @override
  String get valueHint => 'e.g. Oat Cortado';

  @override
  String get removeAttributeTooltip => 'Remove attribute';

  @override
  String get addAnotherButton => 'Add Another';
}
