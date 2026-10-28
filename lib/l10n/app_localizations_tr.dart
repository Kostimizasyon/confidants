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
  String get navProfiles => 'Profiller';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get chatTitle => 'Confidants Yapay Zekâ';

  @override
  String get chatSubtitle => 'Çevrimdışı kişisel bağlam asistanı';

  @override
  String get chatPlaceholderTitle => 'Yerel Yapay Zekâ Sohbeti';

  @override
  String get chatPlaceholderMessage =>
      'Kayıtlı profilleriniz hakkında her şeyi sorun. Bağlam parçaları cihazınızda yerel olarak yüklenir.';

  @override
  String get profilesTitle => 'Profiller';

  @override
  String get profilesSubtitle => 'Kişiler ve kişisel bilgi tabanı';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsSubtitle => 'Güvenlik, görünüm ve yapay zekâ';

  @override
  String get detailSubtitle => 'Profil ayrıntıları ve özel nitelikler';

  @override
  String get newProfileTitle => 'Yeni Confidant Profili';

  @override
  String get unnamedProfile => 'Adsız Profil';

  @override
  String get authVaultLockedTitle => 'Confidants Kasası Kilitli';

  @override
  String get authVaultLockedMessage =>
      'Devam etmek için biyometrik verilerinizle veya cihaz kimlik bilgilerinizle kimliğinizi doğrulayın.';

  @override
  String get authVaultFailedMessage =>
      'Kimlik doğrulama iptal edildi veya başarısız oldu. Çevrimdışı profillere erişmek için kimliğinizi doğrulayın.';

  @override
  String get authUnlockButton => 'Confidants Kilidini Aç';

  @override
  String get authUnlockReason =>
      'Confidants kilidini açmak için kimliğinizi doğrulayın';

  @override
  String get authEnableReason =>
      'Biyometrik başlangıç kilidini etkinleştirmek için kimliğinizi doğrulayın';

  @override
  String get biometricsUnavailable =>
      'Bu cihazda biyometrik kimlik doğrulama kullanılamıyor.';

  @override
  String get darkModeTitle => 'Karanlık Mod';

  @override
  String get darkModeSubtitleOn => 'Koyu mavi ve karbon teması etkin';

  @override
  String get darkModeSubtitleOff => 'Yüksek kontrastlı açık tema etkin';

  @override
  String get biometricLockTitle => 'Biyometrik Başlangıç Kilidi';

  @override
  String get biometricLockSubtitle =>
      'Açılışta parmak izi veya cihaz doğrulaması iste';

  @override
  String get trainingTitle => 'Yapay Zekâ Bilgi Tabanına Dahil Et';

  @override
  String get trainingSubtitle =>
      'Bu profili yerel mini-LLM bağlam parçalarına aktar';

  @override
  String get aiOptInTitle => 'Yerel Yapay Zekâ Asistanını Etkinleştir';

  @override
  String get aiOptInSubtitle =>
      'Profillerinizi cihaz içi mini-LLM ile sorgulamak için onay verin';

  @override
  String get aiModelSectionTitle => 'Yapay Zekâ Model Yapılandırması';

  @override
  String get aiModelDropdownLabel => 'Cihaz İçi Model Seçin';

  @override
  String get aiModelSmolTitle => 'SmolLM2 360M Instruct';

  @override
  String get aiModelSmolSpecs => 'Depolama: ~250 MB • RAM: ~450 MB';

  @override
  String get aiModelSmolWarning =>
      'Çok düşük bellek kullanımı. Minimum pil tüketimiyle neredeyse her cihazda akıcı çalışır; basit İngilizce anahtar kelime aramaları için uygundur.';

  @override
  String get aiModelQwenHalfTitle => 'Qwen 2.5 0.5B Instruct (Varsayılan)';

  @override
  String get aiModelQwenHalfSpecs => 'Depolama: ~350 MB • RAM: ~600 MB';

  @override
  String get aiModelQwenHalfWarning =>
      'Düşük depolama ve RAM kullanımı. Çoğu telefonda hızlı yanıt verir ve temel İngilizce bağlam hatırlamayı güvenilir şekilde yapar.';

  @override
  String get aiModelLlamaOneTitle => 'Llama 3.2 1B Instruct';

  @override
  String get aiModelLlamaOneSpecs => 'Depolama: ~750 MB • RAM: ~1.3 GB';

  @override
  String get aiModelLlamaOneWarning =>
      'Orta düzeyde indirme boyutu ve RAM kullanımı. Daha güçlü İngilizce sohbet yeteneği sunar ancak eski cihazları ısıtabilir.';

  @override
  String get aiModelQwenOneHalfTitle => 'Qwen 2.5 1.5B Instruct';

  @override
  String get aiModelQwenOneHalfSpecs => 'Depolama: ~1.0 GB • RAM: ~1.8 GB';

  @override
  String get aiModelQwenOneHalfWarning =>
      '~1 GB depolama ve yaklaşık 2 GB boş RAM gerektirir. Çoklu profil çıkarımlarında daha başarılıdır; orta ve üst segment cihazlar için önerilir.';

  @override
  String get aiModelLlamaThreeTitle => 'Llama 3.2 3B Instruct';

  @override
  String get aiModelLlamaThreeSpecs => 'Depolama: ~2.0 GB • RAM: ~3.2 GB';

  @override
  String get aiModelLlamaThreeWarning =>
      'Yüksek depolama ve RAM uyarısı: 2 GB disk alanı ve 3 GB\'tan fazla boş RAM gerektirir. Düşük bellekli telefonlarda yavaşlamaya veya çökmelere yol açabilir.';

  @override
  String get aiModelCustomTitle => 'Özel Yerel Model (.gguf)';

  @override
  String get aiModelCustomSpecs =>
      'Depolama ve RAM: Seçtiğiniz .gguf dosyasına bağlıdır';

  @override
  String get aiModelCustomWarning =>
      'Uyarı: Büyük modeller (>2 GB) mobil RAM sınırlarını aşarak uygulamayı çökertebilir. 0.5B ile 1.5B arasında Q4_K_M modelleri tercih edin.';

  @override
  String get aiModelCustomSubtitleUnset =>
      'Henüz özel bir .gguf dosya yolu seçilmedi';

  @override
  String get aiModelCustomChangeButton => '.gguf Yolu Seç';

  @override
  String get aiModelCustomDialogTitle => 'Özel Model Yolu Belirle';

  @override
  String get aiModelCustomPathLabel => 'Yerel .gguf Dosya Yolu';

  @override
  String get aiModelCustomPathHint => '/storage/emulated/0/Download/model.gguf';

  @override
  String get aiModelCustomSaveButton => 'Modeli Kullan';

  @override
  String get aiModelCustomCancelButton => 'İptal';

  @override
  String aiModelSwitchedToast(String modelName) {
    return 'Etkin model $modelName olarak ayarlandı.';
  }

  @override
  String get aiModelCustomInvalidToast =>
      'Lütfen geçerli bir .gguf dosya yolu girin.';

  @override
  String get chatOptInRequiredTitle => 'Yerel Yapay Zekâ Devre Dışı';

  @override
  String get chatOptInRequiredSubtitle =>
      'Cihaz içi profil sorgulamayı açmak için Ayarlar\'dan veya aşağıdaki düğmeden etkinleştirin.';

  @override
  String get chatOptInButton => 'Yerel Yapay Zekâyı Etkinleştir';

  @override
  String get chatEmptyTitle => 'Confidant\'larınız Hakkında Sorun';

  @override
  String chatEmptySubtitle(String modelName, int chunkCount) {
    String _temp0 = intl.Intl.pluralLogic(
      chunkCount,
      locale: localeName,
      other: 'Bellekte $chunkCount profil parçası var',
      one: 'Bellekte 1 profil parçası var',
      zero: 'Henüz profil parçası dizine eklenmedi',
    );
    return 'Etkin model: $modelName • $_temp0';
  }

  @override
  String get chatInputHint =>
      'Doğum günleri, kahve tercihleri, hobiler hakkında sorun...';

  @override
  String get chatClearTooltip => 'Sohbeti Temizle';

  @override
  String get chatClearedToast => 'Sohbet temizlendi.';

  @override
  String get chatGeneratingStatus => 'Düşünüyor...';

  @override
  String get chatErrorResponse =>
      'Yerel yapay zekâ bağlamından yanıt üretilemedi.';

  @override
  String get chatNoContextResponse =>
      'Henüz eğitim için etkinleştirilmiş bir profil parçası yok. Önce Profiller sekmesinden bir profil ekleyin.';

  @override
  String chatMockPrefix(String modelName, int chunkCount, String summary) {
    return '[$modelName • bağlamda $chunkCount parça]\n$summary';
  }

  @override
  String get chatNoMatchSummary =>
      'Dışa aktarılan profil bağlam parçalarını kontrol ettim ancak bu sorguyla doğrudan eşleşen bir bilgi bulamadım. Kişinin adı, takma adı, doğum günü, sevdikleri veya özel nitelikleriyle sormayı deneyin.';

  @override
  String get searchProfilesHint =>
      'Profilleri ad, telefon veya nota göre ara...';

  @override
  String get importFromContactsTooltip => 'Kişilerden İçe Aktar';

  @override
  String get newProfileTooltip => 'Yeni Profil';

  @override
  String get addProfileButton => 'Profil Ekle';

  @override
  String get noContactsFound => 'Kişi bulunamadı veya izin reddedildi.';

  @override
  String get emptyInitialTitle => 'Henüz Confidant Profili Yok';

  @override
  String get emptyInitialSubtitle =>
      'Rehberinizden bir kişi aktarın veya zengin bir kişisel profili elle oluşturun.';

  @override
  String get importContactButton => 'Kişi Aktar';

  @override
  String get createManuallyButton => 'Elle Oluştur';

  @override
  String get emptySearchTitle => 'Eşleşen Profil Yok';

  @override
  String get emptySearchSubtitle =>
      'Arama kelimelerinizi veya telefon filtrenizi değiştirmeyi deneyin.';

  @override
  String get importDeviceContactTitle => 'Cihazdan Kişi Aktar';

  @override
  String get searchContactsHint => 'Kişileri ad veya telefona göre ara...';

  @override
  String get noMatchingContacts => 'Eşleşen kişi bulunamadı.';

  @override
  String get enterNameError => 'Lütfen bu profil için bir ad girin.';

  @override
  String profileSaved(String name) {
    return '$name için profil kaydedildi.';
  }

  @override
  String profileDeleted(String name) {
    return '$name silindi.';
  }

  @override
  String get deleteProfileTooltip => 'Profili Sil';

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
  String get saveProfileButton => 'Profili Kaydet';

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
}
