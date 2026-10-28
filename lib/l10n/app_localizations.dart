import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// Application name shown in the OS task switcher.
  ///
  /// In en, this message translates to:
  /// **'Confidants'**
  String get appTitle;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navProfiles.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get navProfiles;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Confidants AI'**
  String get chatTitle;

  /// No description provided for @chatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Offline personal context assistant'**
  String get chatSubtitle;

  /// No description provided for @chatPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Local AI Chat Interface'**
  String get chatPlaceholderTitle;

  /// No description provided for @chatPlaceholderMessage.
  ///
  /// In en, this message translates to:
  /// **'Ask anything about your saved profiles. Context chunks are loaded locally on your device.'**
  String get chatPlaceholderMessage;

  /// No description provided for @profilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get profilesTitle;

  /// No description provided for @profilesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Contacts & personal knowledge base'**
  String get profilesSubtitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Security, appearance & AI'**
  String get settingsSubtitle;

  /// No description provided for @detailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Profile details & custom attributes'**
  String get detailSubtitle;

  /// No description provided for @newProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'New Confidant Profile'**
  String get newProfileTitle;

  /// No description provided for @unnamedProfile.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Profile'**
  String get unnamedProfile;

  /// No description provided for @authVaultLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Confidants Vault Locked'**
  String get authVaultLockedTitle;

  /// No description provided for @authVaultLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity with biometrics or device credentials to continue.'**
  String get authVaultLockedMessage;

  /// No description provided for @authVaultFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Authentication was canceled or did not succeed. Verify your identity to access offline profiles.'**
  String get authVaultFailedMessage;

  /// No description provided for @authUnlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock Confidants'**
  String get authUnlockButton;

  /// No description provided for @authUnlockReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to unlock Confidants'**
  String get authUnlockReason;

  /// No description provided for @authEnableReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm your identity to enable biometric launch lock'**
  String get authEnableReason;

  /// No description provided for @biometricsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not available on this device.'**
  String get biometricsUnavailable;

  /// No description provided for @darkModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeTitle;

  /// No description provided for @darkModeSubtitleOn.
  ///
  /// In en, this message translates to:
  /// **'Dark blue & carbon theme active'**
  String get darkModeSubtitleOn;

  /// No description provided for @darkModeSubtitleOff.
  ///
  /// In en, this message translates to:
  /// **'High-contrast light theme active'**
  String get darkModeSubtitleOff;

  /// No description provided for @biometricLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Biometric Launch Lock'**
  String get biometricLockTitle;

  /// No description provided for @biometricLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require fingerprint or device authentication on startup'**
  String get biometricLockSubtitle;

  /// No description provided for @trainingTitle.
  ///
  /// In en, this message translates to:
  /// **'Include in AI Knowledge Base'**
  String get trainingTitle;

  /// No description provided for @trainingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export this profile to local mini-LLM context chunks'**
  String get trainingSubtitle;

  /// No description provided for @aiOptInTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Local AI Assistant'**
  String get aiOptInTitle;

  /// No description provided for @aiOptInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Opt in to query your profiles with an on-device mini-LLM'**
  String get aiOptInSubtitle;

  /// No description provided for @aiModelSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Model Configuration'**
  String get aiModelSectionTitle;

  /// No description provided for @aiModelDropdownLabel.
  ///
  /// In en, this message translates to:
  /// **'Select On-Device Model'**
  String get aiModelDropdownLabel;

  /// No description provided for @aiModelSmolTitle.
  ///
  /// In en, this message translates to:
  /// **'SmolLM2 360M Instruct'**
  String get aiModelSmolTitle;

  /// No description provided for @aiModelSmolSpecs.
  ///
  /// In en, this message translates to:
  /// **'Storage: ~250 MB • RAM: ~450 MB'**
  String get aiModelSmolSpecs;

  /// No description provided for @aiModelSmolWarning.
  ///
  /// In en, this message translates to:
  /// **'Featherlight footprint. Runs smoothly on almost any device with minimal battery impact, best for simple English keyword lookups.'**
  String get aiModelSmolWarning;

  /// No description provided for @aiModelQwenHalfTitle.
  ///
  /// In en, this message translates to:
  /// **'Qwen 2.5 0.5B Instruct (Default)'**
  String get aiModelQwenHalfTitle;

  /// No description provided for @aiModelQwenHalfSpecs.
  ///
  /// In en, this message translates to:
  /// **'Storage: ~350 MB • RAM: ~600 MB'**
  String get aiModelQwenHalfSpecs;

  /// No description provided for @aiModelQwenHalfWarning.
  ///
  /// In en, this message translates to:
  /// **'Low storage and memory usage. Fast response speed on most phones and handles basic English context recall reliably.'**
  String get aiModelQwenHalfWarning;

  /// No description provided for @aiModelLlamaOneTitle.
  ///
  /// In en, this message translates to:
  /// **'Llama 3.2 1B Instruct'**
  String get aiModelLlamaOneTitle;

  /// No description provided for @aiModelLlamaOneSpecs.
  ///
  /// In en, this message translates to:
  /// **'Storage: ~750 MB • RAM: ~1.3 GB'**
  String get aiModelLlamaOneSpecs;

  /// No description provided for @aiModelLlamaOneWarning.
  ///
  /// In en, this message translates to:
  /// **'Moderate download and RAM usage. Stronger conversational English reasoning, but may warm up older devices.'**
  String get aiModelLlamaOneWarning;

  /// No description provided for @aiModelQwenOneHalfTitle.
  ///
  /// In en, this message translates to:
  /// **'Qwen 2.5 1.5B Instruct'**
  String get aiModelQwenOneHalfTitle;

  /// No description provided for @aiModelQwenOneHalfSpecs.
  ///
  /// In en, this message translates to:
  /// **'Storage: ~1.0 GB • RAM: ~1.8 GB'**
  String get aiModelQwenOneHalfSpecs;

  /// No description provided for @aiModelQwenOneHalfWarning.
  ///
  /// In en, this message translates to:
  /// **'Requires ~1 GB storage and nearly 2 GB free RAM. Better multi-profile reasoning, recommended for mid-to-high-tier devices.'**
  String get aiModelQwenOneHalfWarning;

  /// No description provided for @aiModelLlamaThreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Llama 3.2 3B Instruct'**
  String get aiModelLlamaThreeTitle;

  /// No description provided for @aiModelLlamaThreeSpecs.
  ///
  /// In en, this message translates to:
  /// **'Storage: ~2.0 GB • RAM: ~3.2 GB'**
  String get aiModelLlamaThreeSpecs;

  /// No description provided for @aiModelLlamaThreeWarning.
  ///
  /// In en, this message translates to:
  /// **'Heavy storage and RAM warning: Needs 2 GB disk space and over 3 GB free RAM. May cause slowdowns or out-of-memory crashes on budget phones.'**
  String get aiModelLlamaThreeWarning;

  /// No description provided for @aiModelCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Local Model (.gguf)'**
  String get aiModelCustomTitle;

  /// No description provided for @aiModelCustomSpecs.
  ///
  /// In en, this message translates to:
  /// **'Storage & RAM: Depends on your .gguf file'**
  String get aiModelCustomSpecs;

  /// No description provided for @aiModelCustomWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Large quantizations (>2 GB) can exceed mobile RAM limits and crash the app. Prefer Q4_K_M models between 0.5B and 1.5B.'**
  String get aiModelCustomWarning;

  /// No description provided for @aiModelCustomSubtitleUnset.
  ///
  /// In en, this message translates to:
  /// **'No custom .gguf file path selected yet'**
  String get aiModelCustomSubtitleUnset;

  /// No description provided for @aiModelCustomChangeButton.
  ///
  /// In en, this message translates to:
  /// **'Choose .gguf Path'**
  String get aiModelCustomChangeButton;

  /// No description provided for @aiModelCustomDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Custom Model Path'**
  String get aiModelCustomDialogTitle;

  /// No description provided for @aiModelCustomPathLabel.
  ///
  /// In en, this message translates to:
  /// **'Local .gguf File Path'**
  String get aiModelCustomPathLabel;

  /// No description provided for @aiModelCustomPathHint.
  ///
  /// In en, this message translates to:
  /// **'/storage/emulated/0/Download/model.gguf'**
  String get aiModelCustomPathHint;

  /// No description provided for @aiModelCustomSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Use Model'**
  String get aiModelCustomSaveButton;

  /// No description provided for @aiModelCustomCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get aiModelCustomCancelButton;

  /// No description provided for @aiModelSwitchedToast.
  ///
  /// In en, this message translates to:
  /// **'Active model set to {modelName}.'**
  String aiModelSwitchedToast(String modelName);

  /// No description provided for @aiModelCustomInvalidToast.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid .gguf file path.'**
  String get aiModelCustomInvalidToast;

  /// No description provided for @chatOptInRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Local AI is Disabled'**
  String get chatOptInRequiredTitle;

  /// No description provided for @chatOptInRequiredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Opt in to Local AI in Settings or tap below to enable on-device profile querying.'**
  String get chatOptInRequiredSubtitle;

  /// No description provided for @chatOptInButton.
  ///
  /// In en, this message translates to:
  /// **'Enable Local AI'**
  String get chatOptInButton;

  /// No description provided for @chatEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask About Your Confidants'**
  String get chatEmptyTitle;

  /// No description provided for @chatEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Active model: {modelName} • {chunkCount, plural, =0{No profile chunks indexed yet} =1{1 profile chunk in memory} other{{chunkCount} profile chunks in memory}}'**
  String chatEmptySubtitle(String modelName, int chunkCount);

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about birthdays, coffee orders, hobbies...'**
  String get chatInputHint;

  /// No description provided for @chatClearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear Conversation'**
  String get chatClearTooltip;

  /// No description provided for @chatClearedToast.
  ///
  /// In en, this message translates to:
  /// **'Conversation cleared.'**
  String get chatClearedToast;

  /// No description provided for @chatGeneratingStatus.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get chatGeneratingStatus;

  /// No description provided for @chatErrorResponse.
  ///
  /// In en, this message translates to:
  /// **'Unable to generate a response from local AI context.'**
  String get chatErrorResponse;

  /// No description provided for @chatNoContextResponse.
  ///
  /// In en, this message translates to:
  /// **'No training-enabled profile chunks are indexed yet. Add a profile in the Profiles tab first.'**
  String get chatNoContextResponse;

  /// No description provided for @chatMockPrefix.
  ///
  /// In en, this message translates to:
  /// **'[{modelName} • {chunkCount} chunks in context]\n{summary}'**
  String chatMockPrefix(String modelName, int chunkCount, String summary);

  /// No description provided for @chatNoMatchSummary.
  ///
  /// In en, this message translates to:
  /// **'I checked your exported profile context chunks, but couldn\'t find a direct match for that query. Try asking by a person\'s name, nickname, birthday, likes, or custom attributes.'**
  String get chatNoMatchSummary;

  /// No description provided for @searchProfilesHint.
  ///
  /// In en, this message translates to:
  /// **'Search profiles by name, phone, or notes...'**
  String get searchProfilesHint;

  /// No description provided for @importFromContactsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import from Contacts'**
  String get importFromContactsTooltip;

  /// No description provided for @newProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'New Profile'**
  String get newProfileTooltip;

  /// No description provided for @addProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Add Profile'**
  String get addProfileButton;

  /// No description provided for @noContactsFound.
  ///
  /// In en, this message translates to:
  /// **'No contacts found or permission denied.'**
  String get noContactsFound;

  /// No description provided for @emptyInitialTitle.
  ///
  /// In en, this message translates to:
  /// **'No Confidant Profiles Yet'**
  String get emptyInitialTitle;

  /// No description provided for @emptyInitialSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import a contact from your address book or create a rich personal profile manually.'**
  String get emptyInitialSubtitle;

  /// No description provided for @importContactButton.
  ///
  /// In en, this message translates to:
  /// **'Import Contact'**
  String get importContactButton;

  /// No description provided for @createManuallyButton.
  ///
  /// In en, this message translates to:
  /// **'Create Manually'**
  String get createManuallyButton;

  /// No description provided for @emptySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'No Matching Profiles'**
  String get emptySearchTitle;

  /// No description provided for @emptySearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search keywords or phone number filter.'**
  String get emptySearchSubtitle;

  /// No description provided for @importDeviceContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Device Contact'**
  String get importDeviceContactTitle;

  /// No description provided for @searchContactsHint.
  ///
  /// In en, this message translates to:
  /// **'Search contacts by name or phone...'**
  String get searchContactsHint;

  /// No description provided for @noMatchingContacts.
  ///
  /// In en, this message translates to:
  /// **'No matching contacts found.'**
  String get noMatchingContacts;

  /// No description provided for @enterNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name for this profile.'**
  String get enterNameError;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved for {name}.'**
  String profileSaved(String name);

  /// No description provided for @profileDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {name}.'**
  String profileDeleted(String name);

  /// No description provided for @deleteProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete Profile'**
  String get deleteProfileTooltip;

  /// No description provided for @noPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'No phone number'**
  String get noPhoneNumber;

  /// No description provided for @sha256Label.
  ///
  /// In en, this message translates to:
  /// **'SHA-256: {hash}'**
  String sha256Label(String hash);

  /// No description provided for @customAttributesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No custom attributes} =1{1 custom attribute} other{{count} custom attributes}}'**
  String customAttributesCount(int count);

  /// No description provided for @fieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fieldFullName;

  /// No description provided for @hintFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter contact name'**
  String get hintFullName;

  /// No description provided for @fieldNickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname (Optional)'**
  String get fieldNickname;

  /// No description provided for @hintNickname.
  ///
  /// In en, this message translates to:
  /// **'What do you call them?'**
  String get hintNickname;

  /// No description provided for @fieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get fieldPhone;

  /// No description provided for @hintPhone.
  ///
  /// In en, this message translates to:
  /// **'+1 555 010 9999'**
  String get hintPhone;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address (Optional)'**
  String get fieldEmail;

  /// No description provided for @hintEmail.
  ///
  /// In en, this message translates to:
  /// **'person@example.com'**
  String get hintEmail;

  /// No description provided for @fieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes to Remember'**
  String get fieldNotes;

  /// No description provided for @hintNotes.
  ///
  /// In en, this message translates to:
  /// **'Key personal context, stories, and reminders...'**
  String get hintNotes;

  /// No description provided for @fieldLikes.
  ///
  /// In en, this message translates to:
  /// **'Likes (comma-separated)'**
  String get fieldLikes;

  /// No description provided for @hintLikes.
  ///
  /// In en, this message translates to:
  /// **'Matcha, jazz, sci-fi books'**
  String get hintLikes;

  /// No description provided for @fieldDislikes.
  ///
  /// In en, this message translates to:
  /// **'Dislikes (comma-separated)'**
  String get fieldDislikes;

  /// No description provided for @hintDislikes.
  ///
  /// In en, this message translates to:
  /// **'Crowded places, cilantro'**
  String get hintDislikes;

  /// No description provided for @fieldHobbies.
  ///
  /// In en, this message translates to:
  /// **'Hobbies & Interests (comma-separated)'**
  String get fieldHobbies;

  /// No description provided for @hintHobbies.
  ///
  /// In en, this message translates to:
  /// **'Bouldering, analog photography, chess'**
  String get hintHobbies;

  /// No description provided for @selectBirthday.
  ///
  /// In en, this message translates to:
  /// **'Select Birthday'**
  String get selectBirthday;

  /// No description provided for @birthdayStoredHint.
  ///
  /// In en, this message translates to:
  /// **'ISO 8601 date stored locally'**
  String get birthdayStoredHint;

  /// No description provided for @saveProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfileButton;

  /// No description provided for @customAttributesTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Attributes'**
  String get customAttributesTitle;

  /// No description provided for @addRowButton.
  ///
  /// In en, this message translates to:
  /// **'Add Row'**
  String get addRowButton;

  /// No description provided for @customAttributesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add dynamic key-value pairs (e.g., Favorite Coffee, Allergies, Pet Name).'**
  String get customAttributesEmptyHint;

  /// No description provided for @attributeLabel.
  ///
  /// In en, this message translates to:
  /// **'Attribute'**
  String get attributeLabel;

  /// No description provided for @attributeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Coffee'**
  String get attributeHint;

  /// No description provided for @valueLabel.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get valueLabel;

  /// No description provided for @valueHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Oat Cortado'**
  String get valueHint;

  /// No description provided for @removeAttributeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove attribute'**
  String get removeAttributeTooltip;

  /// No description provided for @addAnotherButton.
  ///
  /// In en, this message translates to:
  /// **'Add Another'**
  String get addAnotherButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
