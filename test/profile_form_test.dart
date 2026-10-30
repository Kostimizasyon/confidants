import 'package:confidants/data_models/user_profile.dart';
import 'package:confidants/frontend/profiles_page/util/profile_form.dart';
import 'package:confidants/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildTestApp({required Widget child}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        child: child,
      ),
    ),
  );
}

void main() {
  group('ProfileForm add to phone contacts check button tests', () {
    testWidgets('shows check button when isNew is true and propagates state onSave', (
      WidgetTester tester,
    ) async {
      UserProfile? savedProfile;
      bool? savedAddToPhonebook;

      final emptyProfile = UserProfile.empty(profileHash: 'hash123');

      await tester.pumpWidget(
        _buildTestApp(
          child: ProfileForm(
            initialProfile: emptyProfile,
            isNew: true,
            onSave: (profile, {bool addToDeviceContacts = false}) {
              savedProfile = profile;
              savedAddToPhonebook = addToDeviceContacts;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check button should be rendered
      final checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);

      // Scroll into view if needed and verify initial state
      await tester.ensureVisible(checkboxFinder);
      await tester.pumpAndSettle();

      Checkbox checkbox = tester.widget(checkboxFinder);
      expect(checkbox.value, isFalse);

      // Tap to check
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      checkbox = tester.widget(checkboxFinder);
      expect(checkbox.value, isTrue);

      // Enter a name so submit succeeds
      final nameField = find.byType(TextField).first;
      await tester.ensureVisible(nameField);
      await tester.enterText(nameField, 'Alice');
      await tester.pumpAndSettle();

      // Tap Save Profile button
      final saveButton = find.byType(FilledButton);
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(savedProfile, isNotNull);
      expect(savedProfile!.name, 'Alice');
      expect(savedAddToPhonebook, isTrue);
    });

    testWidgets('does not show check button when isNew is false and profile has id', (
      WidgetTester tester,
    ) async {
      final existingProfile = UserProfile(
        id: 1,
        profileHash: 'hash456',
        name: 'Bob',
        phoneNumber: '1234567890',
        createdAt: 0,
        updatedAt: 0,
      );

      await tester.pumpWidget(
        _buildTestApp(
          child: ProfileForm(
            initialProfile: existingProfile,
            isNew: false,
            onSave: (profile, {bool addToDeviceContacts = false}) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check button should not be present
      expect(find.byType(Checkbox), findsNothing);
    });
  });
}
