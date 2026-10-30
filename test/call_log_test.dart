import 'package:confidants/data_models/call_entry.dart';
import 'package:confidants/data_models/user_profile.dart';
import 'package:confidants/frontend/dialer_page/dialer_page.dart';
import 'package:confidants/frontend/dialer_page/util/dial_pad.dart';
import 'package:confidants/l10n/app_localizations.dart';
import 'package:confidants/services/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

  group('CallEntry model tests', () {
    test('parses map with different call types and calculates displayTitle', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final incoming = CallEntry.fromMap({
        'id': '1',
        'number': '+905551234567',
        'name': 'Mom',
        'type': 'incoming',
        'timestamp': now,
        'duration': 45,
      });

      expect(incoming.number, '+905551234567');
      expect(incoming.cachedName, 'Mom');
      expect(incoming.type, CallType.incoming);
      expect(incoming.duration.inSeconds, 45);
      expect(incoming.displayTitle, 'Mom');

      final missed = CallEntry.fromMap({
        'id': '2',
        'number': '+15559876543',
        'name': null,
        'type': 'missed',
        'timestamp': now,
        'duration': 0,
      });

      expect(missed.type, CallType.missed);
      expect(missed.displayTitle, '+15559876543');

      // Matched confidant priority
      const confidant = UserProfile(
        profileHash: 'hash-abc',
        name: 'Uncle Bob',
        phoneNumber: '+15559876543',
        createdAt: 0,
        updatedAt: 0,
      );
      final matched = missed.copyWith(matchedConfidant: confidant);
      expect(matched.displayTitle, 'Uncle Bob');
    });
  });

  group('DialerPage Last Calls and Keypad toggle', () {
    Widget createDialerTestApp() {
      return const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: DialerPage(),
      );
    }

    testWidgets('starts in Recent Calls mode and toggles Keypad dial pad via button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createDialerTestApp());
      await tester.pump(const Duration(milliseconds: 300));

      // Should show minimal AppBar with search & 3-dots icons initially
      expect(find.byIcon(LucideIcons.search), findsOneWidget);
      expect(find.byIcon(LucideIcons.ellipsisVertical), findsOneWidget);

      // Should show Open Keypad FAB button
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      expect(find.byIcon(LucideIcons.grid3x3), findsWidgets);

      // Keypad DialPad should not be visible initially
      expect(find.byType(DialPad), findsNothing);

      // Tap FAB to open Keypad mode
      await tester.tap(fab);
      await tester.pump(const Duration(milliseconds: 300));

      // Keypad DialPad should now be visible
      expect(find.byType(DialPad), findsOneWidget);

      // Should have collapse / hide keypad button
      final collapseBtn = find.byIcon(LucideIcons.chevronDown);
      expect(collapseBtn, findsOneWidget);

      // Tap collapse button to return to Recent Calls
      await tester.tap(collapseBtn);
      await tester.pump(const Duration(milliseconds: 300));

      // Recent Calls view should be back
      expect(find.byIcon(LucideIcons.search), findsOneWidget);
      expect(find.byType(DialPad), findsNothing);
    });
  });
}
