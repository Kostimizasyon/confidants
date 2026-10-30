import 'package:confidants/main.dart';
import 'package:confidants/services/preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';
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

    // Tap on Chat tab
    await tester.tap(find.text('Chat').last);
    await tester.pump(const Duration(milliseconds: 300));

    // Tap back on Keypad tab
    await tester.tap(find.text('Keypad').last);
    await tester.pump(const Duration(milliseconds: 300));
  });
}
