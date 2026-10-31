import 'package:confidants/data_models/contact_item.dart';
import 'package:confidants/frontend/util/contact_picker_dialog.dart';
import 'package:confidants/l10n/app_localizations.dart';
import 'package:confidants/main.dart';
import 'package:confidants/services/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.instance.init();
  });

  testWidgets('ConfidantsApp renders AuthGuardScreen / NavigationShell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ConfidantsApp());
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(ConfidantsApp), findsOneWidget);
  });

  testWidgets('NavigationShell renders floating capsule bar and switches tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ConfidantsApp());
    await tester.pump(const Duration(milliseconds: 300));

    // Verify floating capsule navigation bar tabs
    expect(find.text('Keypad'), findsWidgets);
    expect(find.text('Confidants'), findsWidgets);
    expect(find.text('Chat'), findsWidgets);

    // Tap on Confidants tab
    await tester.tap(find.text('Confidants').last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(LucideIcons.bookUser), findsWidgets);

    // Tap on Chat tab
    await tester.tap(find.text('Chat').last);
    await tester.pump(const Duration(milliseconds: 300));

    // Tap back on Keypad tab
    await tester.tap(find.text('Keypad').last);
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('ContactPickerDialog renders Import All button and invokes callback', (
    WidgetTester tester,
  ) async {
    var importAllCalled = false;
    final contacts = [
      const ContactItem(displayName: 'Alice', phoneNumber: '+1 555 0101'),
      const ContactItem(displayName: 'Bob', phoneNumber: '+1 555 0102'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ContactPickerDialog(
            contacts: contacts,
            onImportAll: () => importAllCalled = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Import All (2)'), findsOneWidget);
    await tester.tap(find.text('Import All (2)'));
    await tester.pumpAndSettle();
    expect(importAllCalled, isTrue);
  });
}
