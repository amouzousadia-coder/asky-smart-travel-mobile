import 'package:asky_smart_travel/app.dart';
import 'package:asky_smart_travel/screens/flights/destinations_screen.dart';
import 'package:flutter/material.dart';
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

  testWidgets('Destinations filters by search query', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DestinationsScreen()));

    await tester.enterText(find.byType(TextField), 'Ghana');
    await tester.pump();

    expect(find.text('Accra'), findsOneWidget);
    expect(find.text('Dakar'), findsNothing);
  });

  testWidgets('Destinations filters by region', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DestinationsScreen()));

    await tester.tap(find.text('Afrique centrale').first);
    await tester.pumpAndSettle();

    expect(find.text('Douala'), findsOneWidget);
    expect(find.text('Libreville'), findsOneWidget);
    expect(find.text('Accra'), findsNothing);
  });

  testWidgets('Destinations shows empty state', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DestinationsScreen()));

    await tester.enterText(find.byType(TextField), 'Tokyo');
    await tester.pump();

    expect(find.text('Aucune destination trouvée.'), findsOneWidget);
    expect(find.text('Essayez une autre recherche.'), findsOneWidget);
  });

  testWidgets('Destinations opens details bottom sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DestinationsScreen()));

    await tester.tap(find.text('Accra').last);
    await tester.pumpAndSettle();

    expect(find.text('Ghana · Aéroport : ACC'), findsOneWidget);
    expect(find.text('Rechercher un vol'), findsOneWidget);
  });
}
