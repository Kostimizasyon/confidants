import 'package:confidants/frontend/util/proteinbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  testWidgets('ProteinBar.success displays message, check icon, and closes on tap', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () {
                  ProteinBar.success(context, 'Confidant saved!');
                },
                child: const Text('Show Success'),
              ),
            ),
          ),
        ),
      ),
    );

    // Tap button to show ProteinBar.success
    await tester.tap(find.text('Show Success'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Confidant saved!'), findsOneWidget);
    expect(find.byIcon(LucideIcons.check), findsOneWidget);

    // Tap on the toast to dismiss it immediately
    await tester.tap(find.text('Confidant saved!'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Confidant saved!'), findsNothing);
  });

  testWidgets('ProteinBar.fail displays message, alert icon, and closes on tap', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () {
                  ProteinBar.fail(context, 'Operation failed!');
                },
                child: const Text('Show Fail'),
              ),
            ),
          ),
        ),
      ),
    );

    // Tap button to show ProteinBar.fail
    await tester.tap(find.text('Show Fail'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Operation failed!'), findsOneWidget);
    expect(find.byIcon(LucideIcons.circleAlert), findsOneWidget);

    // Tap on the toast to dismiss it
    await tester.tap(find.text('Operation failed!'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Operation failed!'), findsNothing);
  });
}
