import 'package:confidants/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ConfidantsApp renders AuthGuardScreen / NavigationShell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ConfidantsApp());
    expect(find.byType(ConfidantsApp), findsOneWidget);
  });
}
