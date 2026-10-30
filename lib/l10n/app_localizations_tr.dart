// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Confidants';

  @override
  String get navChat => 'Sohbet';

  @override
  String get navProfiles => 'Sırdaşlar';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get navKeypad => 'Klavye';

  @override
  String get settingsTooltip => 'Ayarlar';

  @override
  String get dialerTitle => 'Klavye';

  @override
  String get dialerSubtitle => 'Numara çevirin veya kişilerinizde arayın';

  @override
  String get dialerEmptyHint => 'Numara ve isim eşleştirmek için rakam yazın';

  @override
  String get dialerNoMatches => 'Eşleşen kişi yok';

  @override
  String get dialerCallTooltip => 'Ara';

  @override
  String get dialerBackspaceTooltip => 'Sil';

  @override
  String get dialerCallFailed => 'Bu cihazda telefon çeviricisi açılamadı.';

  @override
  String get dialerCreateProfile => 'Bu numarayla sırdaş oluştur';

  @override
  String get favoritesSectionTitle => 'Favorilerim';

  @override
  String favoriteAddedToast(String name) {
    return '$name favorilere eklendi.';
  }

  @override
  String favoriteRemovedToast(String name) {
    return '$name favorilerden çıkarıldı.';
  }

  @override
  String get chatTitle => 'Confidants AI';

  @override
  String get chatSubtitle => 'Çevrimdışı kişisel bağlam asistanı';

  @override
  String get chatPlaceholderTitle => 'Yerel Yapay Zeka Sohbet Arayüzü';

  @override
  String get chatPlaceholderMessage =>
      'Kayıtlı sırdaşlarınız hakkında sorular sorun. Bağlam parçaları cihazınızda tamamen yerel olarak işlenir.';

  @override
  String get profilesTitle => 'Sırdaşlar';

  @override
  String get profilesSubtitle => 'Sırdaşlar ve kişisel bilgi tabanı';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsSubtitle => 'Güvenlik, görünüm ve yapay zeka';

  @override
  String get detailSubtitle => 'Sırdaş detayları ve özel nitelikler';

  @override
  String get newProfileTitle => 'Yeni Sırdaş';

  @override
  String get unnamedProfile => 'İsimsiz Sırdaş';

  @override
  String get authVaultLockedTitle => 'Confidants Kasası Kilitli';

  @override
  String get authVaultLockedMessage =>
      'Devam etmek için biyometrik doğrulama veya cihaz parolanız ile kimliğinizi onaylayın.';

  @override
  String get authVaultFailedMessage =>
      'Kimlik doğrulama iptal edildi veya başarısız oldu. Çevrimdışı sırdaşlara erişmek için kimliğinizi doğrulayın.';

  @override
  String get authUnlockButton => 'Confidants Kilidini Aç';

  @override
  String get authUnlockReason =>
      'Confidants kilidini açmak için kimliğinizi doğrulayın';

  @override
  String get authEnableReason =>
      'Açılışta biyometrik kilit özelliğini etkinleştirmek için kimliğinizi onaylayın';

  @override
  String get biometricsUnavailable =>
      'Bu cihazda biyometrik kimlik doğrulama kullanılamıyor.';

  @override
  String get languageTitle => 'Uygulama Dili';

  @override
  String get languageSubtitle => 'Tercih ettiğiniz görüntüleme dilini seçin';

  @override
  String get languageSystem => 'Sistem Varsayılanı';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String languageSwitchedToast(String language) {
    return 'Uygulama dili $language olarak ayarlandı.';
  }

  @override
  String get darkModeTitle => 'Koyu Tema';

  @override
  String get darkModeSubtitleOn => 'Koyu mavi ve karbon teması aktif';

  @override
  String get darkModeSubtitleOff => 'Yüksek kontrastlı açık tema aktif';

  @override
  String get biometricLockTitle => 'Biyometrik Başlangıç Kilidi';

  @override
  String get biometricLockSubtitle =>
      'Uygulama açılışında parmak izi veya cihaz kimlik doğrulaması iste';

  @override
  String get trainingTitle => 'Yapay Zeka Bilgi Tabanına Dahil Et';

  @override
  String get trainingSubtitle =>
      'Bu sırdaşı yerel mini-LLM bağlam parçalarına dışa aktar';

  @override
  String get aiOptInTitle => 'Yerel Yapay Zekayı Etkinleştir';

  @override
  String get aiOptInSubtitle =>
      'Sırdaşlarınızı cihaz içi mini-LLM ile sorgulamak için izin verin';

  @override
  String get aiModelSectionTitle => 'Yapay Zeka Model Yapılandırması';

  @override
  String get aiModelDropdownLabel => 'Cihaz İçi Modeli Seçin';

  @override
  String get aiModelSmolTitle => 'SmolLM2 360M Instruct';

  @override
  String get aiModelSmolSpecs => 'Depolama: ~250 MB • RAM: ~450 MB';

  @override
  String get aiModelSmolWarning =>
      'Tüy kadar hafif boyut. Minimum pil tüketimiyle neredeyse her cihazda akıcı çalışır; basit anahtar kelime sorguları için en iyisidir.';

  @override
  String get aiModelQwenHalfTitle => 'Qwen 2.5 0.5B Instruct (Varsayılan)';

  @override
  String get aiModelQwenHalfSpecs => 'Depolama: ~350 MB • RAM: ~600 MB';

  @override
  String get aiModelQwenHalfWarning =>
      'Düşük depolama ve bellek kullanımı. Çoğu telefonda hızlı yanıt verir ve temel İngilizce bağlam hatırlamayı güvenle yürütür.';

  @override
  String get aiModelLlamaOneTitle => 'Llama 3.2 1B Instruct';

  @override
  String get aiModelLlamaOneSpecs => 'Depolama: ~750 MB • RAM: ~1.3 GB';

  @override
  String get aiModelLlamaOneWarning =>
      'Orta düzey indirme boyutu ve RAM kullanımı. Daha güçlü konuşma mantığı sunar, ancak eski cihazları ısıtabilir.';

  @override
  String get aiModelQwenOneHalfTitle => 'Qwen 2.5 1.5B Instruct';

  @override
  String get aiModelQwenOneHalfSpecs => 'Depolama: ~1.0 GB • RAM: ~1.8 GB';

  @override
  String get aiModelQwenOneHalfWarning =>
      '~1 GB depolama ve yaklaşık 2 GB boş RAM gerektirir. Çoklu sırdaş çıkarımı için daha iyidir, orta ve üst segment cihazlar için önerilir.';

  @override
  String get aiModelLlamaThreeTitle => 'Llama 3.2 3B Instruct';

  @override
  String get aiModelLlamaThreeSpecs => 'Depolama: ~2.0 GB • RAM: ~3.2 GB';

  @override
  String get aiModelLlamaThreeWarning =>
      'Yüksek depolama ve RAM uyarısı: 2 GB disk alanı ve 3 GB\'tan fazla boş RAM gerektirir. Bütçe dostu telefonlarda yavaşlamalara veya bellek yetersizliği çökmelerine yol açabilir.';

  @override
  String aiModelSwitchedToast(String modelName) {
    return 'Aktif model $modelName olarak ayarlandı.';
  }

  @override
  String get chatOptInRequiredTitle => 'Yerel Yapay Zeka Devre Dışı';

  @override
  String get chatOptInRequiredSubtitle =>
      'Ayarlar\'dan Yerel Yapay Zekayı etkinleştirin veya cihaz içi sırdaş sorgulama için aşağıya dokunun.';

  @override
  String get chatOptInButton => 'Yerel Yapay Zekayı Etkinleştir';

  @override
  String get chatEmptyTitle => 'Sırdaşlarınız Hakkında Soru Sorun';

  @override
  String chatEmptySubtitle(String modelName, int chunkCount) {
    String _temp0 = intl.Intl.pluralLogic(
      chunkCount,
      locale: localeName,
      other: 'Bellekte $chunkCount sırdaş parçası',
      one: 'Bellekte 1 sırdaş parçası',
      zero: 'Henüz dizine eklenmiş sırdaş yok',
    );
    return 'Aktif model: $modelName • $_temp0';
  }

  @override
  String get chatInputHint =>
      'Doğum günleri, kahve siparişleri, hobiler hakkında sorun...';

  @override
  String get chatClearTooltip => 'Sohbeti Temizle';

  @override
  String get chatClearedToast => 'Sohbet temizlendi.';

  @override
  String get chatGeneratingStatus => 'Düşünülüyor...';

  @override
  String get chatErrorResponse =>
      'Yerel yapay zeka bağlamından yanıt üretilemedi.';

  @override
  String get chatNoContextResponse =>
      'Henüz yapay zekaya dahil edilmiş sırdaş parçası bulunmuyor. Önce Sırdaşlar sekmesinden bir sırdaş ekleyin.';

  @override
  String chatMockPrefix(String modelName, int chunkCount, String summary) {
    return '[$modelName • Bağlamda $chunkCount parça]\n$summary';
  }

  @override
  String get chatNoMatchSummary =>
      'Dışa aktarılan sırdaş bağlam parçalarını inceledim ancak bu sorguyla doğrudan eşleşen bir bilgi bulamadım. Kişi adı, takma adı, doğum günü, sevdikleri veya özel nitelikleri belirterek sormayı deneyin.';

  @override
  String get searchProfilesHint =>
      'İsim, telefon veya notlara göre sırdaş ara...';

  @override
  String get importFromContactsTooltip => 'Rehberden İçe Aktar';

  @override
  String get newProfileTooltip => 'Yeni Sırdaş';

  @override
  String get addProfileButton => 'Sırdaş Ekle';

  @override
  String get noContactsFound => 'Kişi bulunamadı veya rehber izni verilmedi.';

  @override
  String get emptyInitialTitle => 'Henüz Sırdaş Yok';

  @override
  String get emptyInitialSubtitle =>
      'Rehberinizden bir kişi içe aktarın veya manuel olarak zengin bir kişisel sırdaş oluşturun.';

  @override
  String get importContactButton => 'Kişi İçe Aktar';

  @override
  String get createManuallyButton => 'Manuel Oluştur';

  @override
  String get emptySearchTitle => 'Eşleşen Sırdaş Bulunamadı';

  @override
  String get emptySearchSubtitle =>
      'Arama sözcüklerinizi veya telefon filtresini değiştirmeyi deneyin.';

  @override
  String get importDeviceContactTitle => 'Cihaz Kişisi İçe Aktar';

  @override
  String get searchContactsHint => 'İsim veya telefona göre kişi ara...';

  @override
  String get noMatchingContacts => 'Eşleşen kişi bulunamadı.';

  @override
  String get enterNameError => 'Lütfen bu sırdaş için bir isim girin.';

  @override
  String profileSaved(String name) {
    return '$name için sırdaş kaydedildi.';
  }

  @override
  String profileDeleted(String name) {
    return '$name silindi.';
  }

  @override
  String get deleteProfileTooltip => 'Sırdaşı Sil';

  @override
  String get noPhoneNumber => 'Telefon numarası yok';

  @override
  String sha256Label(String hash) {
    return 'SHA-256: $hash';
  }

  @override
  String customAttributesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count özel nitelik',
      one: '1 özel nitelik',
      zero: 'Özel nitelik yok',
    );
    return '$_temp0';
  }

  @override
  String get sectionBasicInfo => 'Temel Bilgiler';

  @override
  String get sectionBasicInfoSubtitle =>
      'İsim, sırdaş simgesi ve favori durumu';

  @override
  String get sectionContactDetails => 'İletişim Bilgileri';

  @override
  String get sectionContactDetailsSubtitle => 'Telefon, e-posta ve doğum günü';

  @override
  String get sectionPersonalContext => 'Kişisel Bağlam';

  @override
  String get sectionPersonalContextSubtitle =>
      'Notlar, sevdikleri, sevmedikleri ve hobiler';

  @override
  String get sectionCustomAttributes => 'Özel Nitelikler';

  @override
  String get sectionCustomAttributesSubtitle =>
      'Dinamik anahtar-değer çiftleri';

  @override
  String get chooseAvatarTitle => 'Sırdaş Simgesi Seç';

  @override
  String get favoriteTooltip => 'Favorilere Ekle/Çıkar';

  @override
  String get favoriteLabel => 'Favori Sırdaş';

  @override
  String get favoriteSubtitle => 'Sırdaş listenizin en üstüne sabitleyin';

  @override
  String get favoritesOnlyFilter => 'Favoriler';

  @override
  String get allProfilesFilter => 'Tümü';

  @override
  String get fieldFullName => 'Ad Soyad';

  @override
  String get hintFullName => 'Kişinin adını girin';

  @override
  String get fieldNickname => 'Takma Ad (İsteğe Bağlı)';

  @override
  String get hintNickname => 'Ona nasıl hitap ediyorsunuz?';

  @override
  String get fieldPhone => 'Telefon Numarası';

  @override
  String get hintPhone => '+90 555 010 9999';

  @override
  String get fieldEmail => 'E-posta Adresi (İsteğe Bağlı)';

  @override
  String get hintEmail => 'kisi@ornek.com';

  @override
  String get fieldNotes => 'Hatırlanacak Notlar';

  @override
  String get hintNotes =>
      'Önemli kişisel bağlam, hikâyeler ve hatırlatmalar...';

  @override
  String get fieldLikes => 'Sevdikleri (virgülle ayırın)';

  @override
  String get hintLikes => 'Matcha, caz, bilim kurgu kitapları';

  @override
  String get fieldDislikes => 'Sevmedikleri (virgülle ayırın)';

  @override
  String get hintDislikes => 'Kalabalık yerler, kişniş';

  @override
  String get fieldHobbies => 'Hobiler ve İlgi Alanları (virgülle ayırın)';

  @override
  String get hintHobbies => 'Kaya tırmanışı, analog fotoğrafçılık, satranç';

  @override
  String get selectBirthday => 'Doğum Günü Seç';

  @override
  String get birthdayStoredHint => 'ISO 8601 tarihi yerel olarak saklanır';

  @override
  String get saveProfileButton => 'Sırdaşı Kaydet';

  @override
  String get customAttributesTitle => 'Özel Nitelikler';

  @override
  String get addRowButton => 'Satır Ekle';

  @override
  String get customAttributesEmptyHint =>
      'Dinamik anahtar-değer çiftleri ekleyin (ör. Favori Kahve, Alerjiler, Evcil Hayvan Adı).';

  @override
  String get attributeLabel => 'Nitelik';

  @override
  String get attributeHint => 'ör. Kahve';

  @override
  String get valueLabel => 'Değer';

  @override
  String get valueHint => 'ör. Yulaflı Cortado';

  @override
  String get removeAttributeTooltip => 'Niteliği kaldır';

  @override
  String get addAnotherButton => 'Bir Tane Daha Ekle';

  @override
  String get addToPhonebookTitle => 'Telefon Rehberine Ekle';

  @override
  String get addToPhonebookSubtitle =>
      'Bu kişiyi cihazınızın rehberine de kaydedin';

  @override
  String get phonebookSaveFailed => 'Kişi cihaz rehberine kaydedilemedi.';

  @override
  String profileAndPhonebookSaved(String name) {
    return '$name için sırdaş ve telefon kişisi kaydedildi.';
  }
}
