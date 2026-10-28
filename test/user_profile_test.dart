import 'package:confidants/data_models/user_profile.dart';
import 'package:confidants/frontend/util/avatar_icon_helper.dart';
import 'package:confidants/services/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('UserProfile Avatar & Favorite Tests', () {
    test('Default user profile has user avatar and is not favorite', () {
      final profile = UserProfile.empty(profileHash: 'hash123');
      expect(profile.avatarIcon, 'user');
      expect(profile.isFavorite, isFalse);
    });

    test('Custom avatar and favorite status serialize and deserialize correctly', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final profile = UserProfile(
        id: 1,
        profileHash: 'hash_test_456',
        name: 'Jane Doe',
        phoneNumber: '+15551234567',
        avatarIcon: 'sparkles',
        isFavorite: true,
        createdAt: now,
        updatedAt: now,
      );

      final map = profile.toMap();
      expect(map['avatar_icon'], 'sparkles');
      expect(map['is_favorite'], 1);

      final reconstructed = UserProfile.fromMap(map);
      expect(reconstructed.avatarIcon, 'sparkles');
      expect(reconstructed.isFavorite, isTrue);

      final exportJson = profile.toExportJson();
      expect(exportJson['avatar_icon'], 'sparkles');
      expect(exportJson['is_favorite'], true);
    });

    test('AvatarIconHelper resolves known and unknown icons properly', () {
      expect(AvatarIconHelper.resolve('star'), LucideIcons.star);
      expect(AvatarIconHelper.resolve('sparkles'), LucideIcons.sparkles);
      expect(AvatarIconHelper.resolve('unknown_xyz'), LucideIcons.user);
      expect(AvatarIconHelper.resolve(null), LucideIcons.user);
    });
  });

  group('PreferencesService Language Switcher Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Default locale is system (null Locale)', () async {
      final prefs = PreferencesService.instance;
      await prefs.init();

      expect(prefs.languageCode, 'system');
      expect(prefs.activeLocale, isNull);
    });

    test('Switching to English updates languageCode and activeLocale', () async {
      final prefs = PreferencesService.instance;
      await prefs.init();

      await prefs.setLocaleCode('en');
      expect(prefs.languageCode, 'en');
      expect(prefs.activeLocale, const Locale('en'));
    });

    test('Switching to Turkish updates languageCode and activeLocale', () async {
      final prefs = PreferencesService.instance;
      await prefs.init();

      await prefs.setLocaleCode('tr');
      expect(prefs.languageCode, 'tr');
      expect(prefs.activeLocale, const Locale('tr'));
    });
  });
}
