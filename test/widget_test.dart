import 'package:asky_smart_travel/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ASKY Smart Travel starts on the home tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AskySmartTravelApp());

    expect(find.text('Accueil'), findsWidgets);
    expect(find.text('Réserver'), findsOneWidget);
    expect(find.text('Mon voyage'), findsOneWidget);
    expect(find.text('Plus'), findsOneWidget);
  });
}
