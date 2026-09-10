import 'package:asky_smart_travel/app.dart';
import 'package:asky_smart_travel/core/routes/app_routes.dart';
import 'package:asky_smart_travel/screens/auth/forgot_password_screen.dart';
import 'package:asky_smart_travel/screens/auth/login_screen.dart';
import 'package:asky_smart_travel/screens/auth/register_screen.dart';
import 'package:asky_smart_travel/screens/baggage/baggage_screen.dart';
import 'package:asky_smart_travel/screens/flights/destinations_screen.dart';
import 'package:asky_smart_travel/screens/home/dashboard_screen.dart';
import 'package:asky_smart_travel/screens/loyalty/loyalty_screen.dart';
import 'package:asky_smart_travel/screens/notifications/notifications_screen.dart';
import 'package:asky_smart_travel/screens/profile/profile_screen.dart';
import 'package:asky_smart_travel/screens/support/my_requests_screen.dart';
import 'package:asky_smart_travel/screens/support/support_screen.dart';
import 'package:asky_smart_travel/screens/trips/my_trips_screen.dart';
import 'package:asky_smart_travel/screens/trips/trip_checklist_screen.dart';
import 'package:asky_smart_travel/screens/trips/trip_details_screen.dart';
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

  testWidgets('Login screen displays passenger login form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildLoginTestApp());

    expect(find.text('Bienvenue'), findsOneWidget);
    expect(find.text('ASKY Smart Travel'), findsOneWidget);
    expect(find.text('Adresse e-mail'), findsOneWidget);
    expect(find.text('Mot de passe'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.textContaining('administrateur'), findsNothing);
  });

  testWidgets('Login validates empty email and password', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildLoginTestApp());

    await tester.tap(find.text('Se connecter'));
    await tester.pump();

    expect(find.text('Veuillez saisir votre adresse e-mail.'), findsOneWidget);
    expect(find.text('Veuillez saisir votre mot de passe.'), findsOneWidget);
  });

  testWidgets('Login validates invalid email format', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildLoginTestApp());

    await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
    await tester.enterText(find.byType(TextFormField).last, 'password');
    await tester.tap(find.text('Se connecter'));
    await tester.pump();

    expect(
      find.text('Veuillez saisir une adresse e-mail valide.'),
      findsOneWidget,
    );
  });

  testWidgets('Login toggles password visibility', (WidgetTester tester) async {
    await tester.pumpWidget(_buildLoginTestApp());

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    expect(find.byIcon(Icons.visibility_outlined), findsNothing);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });

  testWidgets('Login register link navigates to register route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildLoginTestApp());

    await tester.tap(find.text('Créer un compte'));
    await tester.pumpAndSettle();

    expect(find.text('Register route'), findsOneWidget);
  });

  testWidgets('Login forgot password link navigates to forgot password route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildLoginTestApp());

    await tester.tap(find.text('Mot de passe oublié ?'));
    await tester.pumpAndSettle();

    expect(find.text('Forgot password route'), findsOneWidget);
  });

  testWidgets('Register screen displays passenger form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildRegisterTestApp());

    expect(find.text('Créer un compte'), findsOneWidget);
    expect(find.text('Prénom'), findsOneWidget);
    expect(find.text('Nom'), findsOneWidget);
    expect(find.text('Adresse e-mail'), findsOneWidget);
    expect(find.text('Téléphone'), findsOneWidget);
    expect(find.text('Date de naissance'), findsOneWidget);
    expect(find.text('Nationalité'), findsOneWidget);
    expect(find.text('Créer mon compte'), findsOneWidget);
    expect(find.textContaining('administrateur'), findsNothing);
    expect(find.textContaining('Administrateur'), findsNothing);
  });

  testWidgets('Register validates required fields and terms', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildRegisterTestApp());

    await tester.ensureVisible(find.text('Créer mon compte'));
    await tester.tap(find.text('Créer mon compte'));
    await tester.pump();

    expect(find.text('Veuillez saisir votre prénom.'), findsOneWidget);
    expect(find.text('Veuillez saisir votre nom.'), findsOneWidget);
    expect(find.text('Veuillez saisir votre adresse e-mail.'), findsOneWidget);
    expect(find.text('Veuillez saisir votre téléphone.'), findsOneWidget);
    expect(find.text('Veuillez saisir votre mot de passe.'), findsOneWidget);
    expect(find.text('Veuillez confirmer votre mot de passe.'), findsOneWidget);
    expect(
      find.text('Veuillez accepter les conditions pour continuer.'),
      findsOneWidget,
    );
  });

  testWidgets('Register validates email format', (WidgetTester tester) async {
    await tester.pumpWidget(_buildRegisterTestApp());

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Adresse e-mail'),
      'bad-email',
    );
    await tester.ensureVisible(find.text('Créer mon compte'));
    await tester.tap(find.text('Créer mon compte'));
    await tester.pump();

    expect(
      find.text('Veuillez saisir une adresse e-mail valide.'),
      findsOneWidget,
    );
  });

  testWidgets('Register validates short and mismatched passwords', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildRegisterTestApp());

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mot de passe'),
      'short',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirmer le mot de passe'),
      'different',
    );
    await tester.ensureVisible(find.text('Créer mon compte'));
    await tester.tap(find.text('Créer mon compte'));
    await tester.pump();

    expect(
      find.text('Le mot de passe doit contenir au moins 8 caractères.'),
      findsOneWidget,
    );
    expect(
      find.text('Les mots de passe ne correspondent pas.'),
      findsOneWidget,
    );
  });

  testWidgets('Register toggles password visibility', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildRegisterTestApp());

    expect(find.byIcon(Icons.visibility_outlined), findsNWidgets(2));

    await tester.ensureVisible(find.byIcon(Icons.visibility_outlined).first);
    await tester.tap(find.byIcon(Icons.visibility_outlined).first);
    await tester.pump();

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });

  testWidgets('Register login link navigates to login route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildRegisterTestApp());

    await tester.ensureVisible(find.text('Se connecter'));
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.text('Login route'), findsOneWidget);
  });

  testWidgets('Forgot password screen displays form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildForgotPasswordTestApp());

    expect(find.text('Mot de passe oublié ?'), findsOneWidget);
    expect(find.text('Adresse e-mail'), findsOneWidget);
    expect(find.text('Envoyer les instructions'), findsOneWidget);
    expect(find.text('Retour à la connexion'), findsOneWidget);
  });

  testWidgets('Forgot password validates empty email', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildForgotPasswordTestApp());

    await tester.tap(find.text('Envoyer les instructions'));
    await tester.pump();

    expect(find.text('Veuillez saisir votre adresse e-mail.'), findsOneWidget);
  });

  testWidgets('Forgot password validates invalid email', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildForgotPasswordTestApp());

    await tester.enterText(find.byType(TextFormField), 'email-invalide');
    await tester.tap(find.text('Envoyer les instructions'));
    await tester.pump();

    expect(
      find.text('Veuillez saisir une adresse e-mail valide.'),
      findsOneWidget,
    );
  });

  testWidgets('Forgot password shows generic confirmation after valid email', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildForgotPasswordTestApp());

    await tester.enterText(find.byType(TextFormField), 'passager@example.com');
    await tester.tap(find.text('Envoyer les instructions'));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Vérifiez votre boîte mail'), findsOneWidget);
    expect(
      find.text(
        'Si un compte est associé à cette adresse, vous recevrez les instructions nécessaires pour réinitialiser votre mot de passe.',
      ),
      findsOneWidget,
    );
    expect(find.text('Renvoyer'), findsOneWidget);
  });

  testWidgets('Forgot password back to login navigates to login route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildForgotPasswordTestApp());

    await tester.tap(find.text('Retour à la connexion'));
    await tester.pumpAndSettle();

    expect(find.text('Login route'), findsOneWidget);
  });

  testWidgets('Forgot password resend shows snackbar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildForgotPasswordTestApp());

    await tester.enterText(find.byType(TextFormField), 'passager@example.com');
    await tester.tap(find.text('Envoyer les instructions'));
    await tester.pump(const Duration(milliseconds: 700));

    await tester.ensureVisible(find.text('Renvoyer'));
    await tester.tap(find.text('Renvoyer'));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Instructions renvoyées.'), findsOneWidget);
  });

  testWidgets('Dashboard displays passenger trip overview', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildDashboardTestApp());

    expect(find.text('Bonjour, Diane'), findsOneWidget);
    expect(find.text('Votre prochain voyage'), findsOneWidget);
    expect(find.text('PROCHAIN VOYAGE · KP 020'), findsOneWidget);
    expect(find.text('Réf. ASKY7D2'), findsOneWidget);
    expect(find.text('À l’heure'), findsWidgets);
    expect(find.text('J - 2 jours'), findsOneWidget);
    expect(find.text('Préparation du voyage'), findsOneWidget);
    expect(find.text('1 / 4'), findsOneWidget);
  });

  testWidgets('Dashboard displays checklist quick actions and smart travel', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildDashboardTestApp());

    await tester.ensureVisible(find.text('À faire avant le départ'));

    expect(find.text('1 sur 4 terminé'), findsOneWidget);
    expect(find.text('Actions rapides'), findsOneWidget);
    expect(find.text('Mes voyages'), findsOneWidget);
    expect(find.text('Statut du vol'), findsOneWidget);
    expect(find.text('Assistant'), findsOneWidget);
    expect(find.text('Bagages'), findsOneWidget);

    await tester.ensureVisible(find.text('Smart Travel'));

    expect(find.text('Votre assistant de voyage'), findsOneWidget);
    expect(find.text('Conseil pour votre voyage'), findsOneWidget);
  });

  testWidgets('Dashboard navigates to my trips', (WidgetTester tester) async {
    await tester.pumpWidget(_buildDashboardTestApp());

    await tester.tap(find.text('Voir tous mes voyages'));
    await tester.pumpAndSettle();

    expect(find.text('My trips route'), findsOneWidget);
  });

  testWidgets('Dashboard navigates to notifications', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildDashboardTestApp());

    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Notifications route'), findsOneWidget);
  });

  testWidgets('Dashboard navigates to assistant', (WidgetTester tester) async {
    await tester.pumpWidget(_buildDashboardTestApp());

    await tester.ensureVisible(find.text('Smart Travel'));
    await tester.ensureVisible(find.text('Demander à l’assistant'));
    await tester.tap(find.text('Demander à l’assistant'));
    await tester.pumpAndSettle();

    expect(find.text('Assistant route'), findsOneWidget);
  });

  testWidgets('Dashboard supports empty trip state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildDashboardTestApp(showDemoTrip: false));

    expect(find.text('Aucun voyage à venir'), findsOneWidget);
    expect(
      find.text('Prêt à découvrir votre prochaine destination ?'),
      findsOneWidget,
    );
    expect(find.text('Rechercher un vol'), findsOneWidget);
  });

  testWidgets('My trips displays upcoming trips', (WidgetTester tester) async {
    await tester.pumpWidget(_buildMyTripsTestApp());

    expect(find.text('Mes voyages'), findsOneWidget);
    expect(find.text('À venir (2)'), findsOneWidget);
    expect(find.text('Passés (2)'), findsOneWidget);
    expect(find.text('ASKY7D2'), findsOneWidget);
    expect(find.text('ASKY9K4'), findsOneWidget);
    expect(find.text('Accra'), findsOneWidget);
    expect(find.text('Abidjan'), findsOneWidget);
    expect(find.text('Dans 2 jours'), findsOneWidget);
    expect(find.text('Dans 15 jours'), findsOneWidget);
  });

  testWidgets('My trips switches to past trips', (WidgetTester tester) async {
    await tester.pumpWidget(_buildMyTripsTestApp());

    await tester.tap(find.text('Passés (2)'));
    await tester.pumpAndSettle();

    expect(find.text('ASKY4B8'), findsOneWidget);
    expect(find.text('ASKY2M6'), findsOneWidget);
    expect(find.text('Cotonou'), findsOneWidget);
    expect(find.text('Dakar'), findsOneWidget);
    expect(find.text('Terminé'), findsNWidgets(2));
  });

  testWidgets('My trips navigates to trip details', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildMyTripsTestApp());

    await tester.tap(find.text('Voir le voyage').first);
    await tester.pumpAndSettle();

    expect(find.text('Trip details route'), findsOneWidget);
  });

  testWidgets('My trips supports empty upcoming state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildMyTripsTestApp(showDemoTrips: false));

    expect(find.text('Aucun voyage à venir'), findsOneWidget);
    expect(
      find.text('Prêt à préparer votre prochaine aventure ?'),
      findsOneWidget,
    );
    expect(find.text('Rechercher un vol'), findsOneWidget);
  });

  testWidgets('Trip details displays upcoming trip companion content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTripDetailsTestApp());

    expect(find.text('Mon voyage'), findsOneWidget);
    expect(find.text('ASKY7D2'), findsWidgets);
    expect(find.text('KP 020'), findsOneWidget);
    expect(find.text('Lomé'), findsWidgets);
    expect(find.text('Accra'), findsWidgets);
    expect(find.text('À l’heure'), findsWidgets);
    expect(find.text('Votre parcours'), findsOneWidget);
    expect(find.text('Préparation'), findsOneWidget);
    expect(find.text('À faire avant le départ'), findsOneWidget);
    expect(find.text('Ma réservation'), findsOneWidget);
    expect(find.text('ETKT 032-1234567890'), findsOneWidget);
    expect(find.text('Numéro fictif de démonstration.'), findsOneWidget);
    expect(find.text('Mes bagages'), findsOneWidget);
    expect(find.text('Besoin d’aide pour ce voyage ?'), findsOneWidget);
  });

  testWidgets('Trip details checklist and baggage buttons navigate', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTripDetailsTestApp());

    await tester.ensureVisible(find.text('Voir la checklist'));
    await tester.tap(find.text('Voir la checklist'));
    await tester.pumpAndSettle();
    expect(find.text('Trip checklist route'), findsOneWidget);

    await tester.pumpWidget(_buildTripDetailsTestApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Voir mes bagages'));
    await tester.tap(find.text('Voir mes bagages'));
    await tester.pumpAndSettle();
    expect(find.text('Baggage route'), findsOneWidget);
  });

  testWidgets('Trip details adapts content for past trip', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildTripDetailsTestApp(
        arguments: const {
          'bookingReference': 'ASKY4B8',
          'flightNumber': 'KP 012',
          'departureCity': 'Lomé',
          'departureCode': 'LFW',
          'destinationCity': 'Cotonou',
          'destinationCode': 'COO',
          'departureDate': '20 août 2026',
          'departureTime': '07:45',
          'arrivalTime': '08:20',
          'status': 'Terminé',
          'isPast': true,
        },
      ),
    );

    expect(find.text('ASKY4B8'), findsWidgets);
    expect(find.text('KP 012'), findsOneWidget);
    expect(find.text('Cotonou'), findsWidgets);
    expect(find.text('Terminé'), findsOneWidget);
    expect(find.text('Voyage terminé'), findsOneWidget);
    expect(find.text('Merci d’avoir voyagé avec nous.'), findsOneWidget);
    expect(find.text('À faire avant le départ'), findsNothing);
    expect(find.text('Votre parcours'), findsNothing);
  });

  testWidgets('Trip checklist displays trip tasks and initial progress', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTripChecklistTestApp());

    expect(find.text('Préparer mon voyage'), findsOneWidget);
    expect(find.text('Lomé → Accra'), findsOneWidget);
    expect(find.text('12 septembre 2026'), findsOneWidget);
    expect(find.text('Votre checklist avant départ'), findsOneWidget);
    expect(find.text('1 sur 6 terminé'), findsOneWidget);
    expect(find.text('17 %'), findsOneWidget);
    expect(find.byType(Checkbox), findsNWidgets(6));
    expect(find.text('Réservation confirmée'), findsOneWidget);
    expect(find.text('Vérifier les documents de voyage'), findsWidgets);
    expect(find.text('Vérifier les formalités d’entrée'), findsWidgets);
    expect(find.text('Préparer les bagages'), findsOneWidget);
    expect(find.text('Faire l’enregistrement en ligne'), findsOneWidget);
    expect(find.text('Vérifier l’heure de départ'), findsOneWidget);
    expect(find.text('Important'), findsNWidgets(3));
    expect(find.text('À faire en priorité'), findsOneWidget);
  });

  testWidgets('Trip checklist toggles tasks and updates progress', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTripChecklistTestApp());

    await tester.ensureVisible(
      find.text('Vérifier les documents de voyage').last,
    );
    await tester.tap(find.text('Vérifier les documents de voyage').last);
    await tester.pumpAndSettle();
    expect(find.text('2 sur 6 terminé'), findsOneWidget);
    expect(find.text('33 %'), findsOneWidget);

    await tester.ensureVisible(
      find.text('Vérifier les documents de voyage').last,
    );
    await tester.tap(find.text('Vérifier les documents de voyage').last);
    await tester.pumpAndSettle();
    expect(find.text('1 sur 6 terminé'), findsOneWidget);
    expect(find.text('17 %'), findsOneWidget);
  });

  testWidgets('Trip checklist baggage and assistant links navigate', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTripChecklistTestApp());

    await tester.ensureVisible(find.text('Voir les règles bagages'));
    await tester.tap(find.text('Voir les règles bagages'));
    await tester.pumpAndSettle();
    expect(find.text('Baggage route'), findsOneWidget);

    await tester.pumpWidget(_buildTripChecklistTestApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Demander à l’assistant'));
    await tester.tap(find.text('Demander à l’assistant'));
    await tester.pumpAndSettle();
    expect(find.text('Assistant route'), findsOneWidget);
  });

  testWidgets('Trip checklist displays complete state at 100 percent', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTripChecklistTestApp());

    for (final title in const [
      'Vérifier les documents de voyage',
      'Vérifier les formalités d’entrée',
      'Préparer les bagages',
      'Faire l’enregistrement en ligne',
      'Vérifier l’heure de départ',
    ]) {
      await tester.ensureVisible(find.text(title).last);
      await tester.tap(find.text(title).last);
      await tester.pumpAndSettle();
    }

    expect(find.text('6 sur 6 terminé'), findsOneWidget);
    expect(find.text('100 %'), findsOneWidget);
    expect(find.text('Vous êtes prêt pour votre voyage'), findsOneWidget);
    expect(find.text('Votre checklist est complète.'), findsOneWidget);
    expect(find.text('Vos priorités sont à jour.'), findsOneWidget);
  });

  testWidgets('Trip checklist adapts for past trip', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildTripChecklistTestApp(
        arguments: const {
          'bookingReference': 'ASKY4B8',
          'flightNumber': 'KP 012',
          'departureCity': 'Lomé',
          'destinationCity': 'Cotonou',
          'departureDate': '20 août 2026',
          'isPast': true,
        },
      ),
    );

    expect(find.text('Ce voyage est terminé.'), findsOneWidget);
    expect(find.textContaining('KP 012'), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);
    expect(find.text('Progression globale'), findsNothing);
  });

  testWidgets('Baggage screen displays allowance and baggage items', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildBaggageTestApp());

    expect(find.text('Mes bagages'), findsOneWidget);
    expect(find.text('Lomé → Accra'), findsOneWidget);
    expect(find.textContaining('KP 020'), findsOneWidget);
    expect(find.text('Votre franchise'), findsOneWidget);
    expect(find.text('Maximum : 8 kg'), findsOneWidget);
    expect(find.text('Maximum : 23 kg'), findsOneWidget);
    expect(find.text('Bagages associés au voyage'), findsOneWidget);
    expect(find.text('BG-ASKY-20481'), findsOneWidget);
    expect(find.text('Enregistré'), findsOneWidget);
    expect(find.text('Avec le passager'), findsOneWidget);
  });

  testWidgets('Baggage screen displays tracking and rules', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildBaggageTestApp());

    expect(find.text('Suivi du bagage'), findsOneWidget);
    expect(find.text('Bagage enregistré à Lomé'), findsOneWidget);
    expect(find.text('Contrôle effectué'), findsOneWidget);
    expect(find.text('Chargement dans l’avion'), findsOneWidget);
    expect(find.text('À savoir'), findsOneWidget);
    expect(find.textContaining('objets dangereux'), findsOneWidget);
    expect(find.textContaining('documents importants'), findsOneWidget);
  });

  testWidgets('Baggage screen support assistant and extra actions work', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildBaggageTestApp());

    await tester.ensureVisible(find.text('En savoir plus'));
    await tester.tap(find.text('En savoir plus'));
    await tester.pump();
    expect(find.text('Option à venir.'), findsOneWidget);

    await tester.ensureVisible(find.text('Signaler un problème'));
    await tester.tap(find.text('Signaler un problème'));
    await tester.pumpAndSettle();
    expect(find.text('Support route'), findsOneWidget);

    await tester.pumpWidget(_buildBaggageTestApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Demander à l’assistant'));
    await tester.tap(find.text('Demander à l’assistant'));
    await tester.pumpAndSettle();
    expect(find.text('Assistant route'), findsOneWidget);
  });

  testWidgets('Baggage screen supports no checked baggage state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildBaggageTestApp(showCheckedBaggage: false));

    expect(find.text('Aucun bagage en soute enregistré.'), findsOneWidget);
    expect(
      find.text(
        'Votre bagage cabine reste soumis aux conditions de votre tarif.',
      ),
      findsOneWidget,
    );
    expect(find.text('BG-ASKY-20481'), findsNothing);
  });

  testWidgets('Support screen displays assistance form and categories', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildSupportTestApp());

    expect(find.text('Nouvelle demande'), findsOneWidget);
    expect(find.text('Comment pouvons-nous vous aider ?'), findsOneWidget);
    expect(find.text('Catégorie'), findsOneWidget);

    await tester.tap(find.byKey(const Key('support-category-field')));
    await tester.pumpAndSettle();

    for (final category in const [
      'Réservation',
      'Paiement',
      'Vol retardé / annulé',
      'Bagages',
      'Documents de voyage',
      'Assistance spéciale',
      'ASKY Club',
      'Autre',
    ]) {
      expect(find.text(category).last, findsOneWidget);
    }
  });

  testWidgets('Support screen validates required fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildSupportTestApp());

    await tester.ensureVisible(find.byKey(const Key('support-submit-button')));
    await tester.tap(find.byKey(const Key('support-submit-button')));
    await tester.pump();

    expect(find.text('Veuillez choisir une catégorie.'), findsOneWidget);
    expect(
      find.text('Veuillez saisir le sujet de votre demande.'),
      findsOneWidget,
    );
    expect(
      find.text('Veuillez donner un peu plus de détails.'),
      findsOneWidget,
    );
  });

  testWidgets('Support screen validates short description', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildSupportTestApp());

    await tester.tap(find.byKey(const Key('support-category-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paiement').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('support-subject-field')),
      'Probleme paiement',
    );
    await tester.enterText(
      find.byKey(const Key('support-description-field')),
      'court',
    );
    await tester.ensureVisible(find.byKey(const Key('support-submit-button')));
    await tester.tap(find.byKey(const Key('support-submit-button')));
    await tester.pump();

    expect(
      find.text('Veuillez donner un peu plus de détails.'),
      findsOneWidget,
    );
  });

  testWidgets('Support screen preselects baggage context from arguments', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildSupportTestApp(
        arguments: const {
          'category': 'baggage',
          'bookingReference': 'ASKY7D2',
          'baggageTag': 'BG-ASKY-20481',
          'flightNumber': 'KP 020',
          'departureCity': 'Lomé',
          'destinationCity': 'Accra',
        },
      ),
    );

    expect(find.text('Bagages'), findsOneWidget);
    expect(find.text('ASKY7D2'), findsOneWidget);
    expect(find.text('Lomé → Accra'), findsOneWidget);
    expect(find.text('KP 020'), findsOneWidget);
    expect(find.text('Étiquette du bagage'), findsOneWidget);
    expect(find.text('BG-ASKY-20481'), findsOneWidget);
  });

  testWidgets('Support screen submits valid request and shows success', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildSupportTestApp(
        arguments: const {
          'category': 'baggage',
          'bookingReference': 'ASKY7D2',
          'baggageTag': 'BG-ASKY-20481',
        },
      ),
    );

    await tester.enterText(
      find.byKey(const Key('support-subject-field')),
      'Bagage absent',
    );
    await tester.enterText(
      find.byKey(const Key('support-description-field')),
      'Mon bagage n est pas arrive a destination.',
    );
    await tester.ensureVisible(find.byKey(const Key('support-submit-button')));
    await tester.tap(find.byKey(const Key('support-submit-button')));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Demande envoyée'), findsOneWidget);
    expect(
      find.text('Votre demande ASKY-2048 a bien été enregistrée.'),
      findsOneWidget,
    );
    expect(find.text('Nouveau'), findsOneWidget);
  });

  testWidgets('Support success navigates to my requests and trip details', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildSupportTestApp(
        arguments: const {
          'category': 'baggage',
          'bookingReference': 'ASKY7D2',
          'baggageTag': 'BG-ASKY-20481',
        },
      ),
    );

    await tester.enterText(
      find.byKey(const Key('support-subject-field')),
      'Bagage absent',
    );
    await tester.enterText(
      find.byKey(const Key('support-description-field')),
      'Mon bagage n est pas arrive a destination.',
    );
    await tester.ensureVisible(find.byKey(const Key('support-submit-button')));
    await tester.tap(find.byKey(const Key('support-submit-button')));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byKey(const Key('support-my-requests-button')));
    await tester.pumpAndSettle();
    expect(find.text('My requests route'), findsOneWidget);

    await tester.pumpWidget(
      _buildSupportTestApp(
        arguments: const {
          'category': 'baggage',
          'bookingReference': 'ASKY7D2',
          'baggageTag': 'BG-ASKY-20481',
        },
      ),
    );
    await tester.enterText(
      find.byKey(const Key('support-subject-field')),
      'Bagage absent',
    );
    await tester.enterText(
      find.byKey(const Key('support-description-field')),
      'Mon bagage n est pas arrive a destination.',
    );
    await tester.ensureVisible(find.byKey(const Key('support-submit-button')));
    await tester.tap(find.byKey(const Key('support-submit-button')));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byKey(const Key('support-return-button')));
    await tester.pumpAndSettle();
    expect(find.text('Trip details route'), findsOneWidget);
  });

  testWidgets('Support success returns to dashboard without linked trip', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildSupportTestApp());

    await tester.tap(find.byKey(const Key('support-category-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Autre').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('support-subject-field')),
      'Question generale',
    );
    await tester.enterText(
      find.byKey(const Key('support-description-field')),
      'Je souhaite recevoir une aide concernant mon voyage.',
    );
    await tester.ensureVisible(find.byKey(const Key('support-submit-button')));
    await tester.tap(find.byKey(const Key('support-submit-button')));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byKey(const Key('support-return-button')));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard route'), findsOneWidget);
  });

  testWidgets('My requests displays demo requests and statuses', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildMyRequestsTestApp());

    expect(find.text('Mes demandes'), findsWidgets);
    expect(find.text('ASKY-2048'), findsOneWidget);
    expect(find.text('ASKY-2031'), findsOneWidget);
    expect(find.text('ASKY-1987'), findsOneWidget);
    expect(find.text('ASKY-1942'), findsOneWidget);
    expect(find.text('Nouveau'), findsOneWidget);
    expect(find.text('En traitement'), findsOneWidget);
    expect(find.text('Résolu'), findsOneWidget);
    expect(find.text('Fermé'), findsOneWidget);
  });

  testWidgets('My requests filters open and resolved requests', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildMyRequestsTestApp());

    await tester.tap(find.text('En cours'));
    await tester.pumpAndSettle();

    expect(find.text('ASKY-2048'), findsOneWidget);
    expect(find.text('ASKY-2031'), findsOneWidget);
    expect(find.text('ASKY-1987'), findsNothing);
    expect(find.text('ASKY-1942'), findsNothing);

    await tester.tap(find.text('Résolues'));
    await tester.pumpAndSettle();

    expect(find.text('ASKY-2048'), findsNothing);
    expect(find.text('ASKY-2031'), findsNothing);
    expect(find.text('ASKY-1987'), findsOneWidget);
    expect(find.text('ASKY-1942'), findsOneWidget);

    await tester.tap(find.text('Toutes'));
    await tester.pumpAndSettle();

    expect(find.text('ASKY-2048'), findsOneWidget);
    expect(find.text('ASKY-1942'), findsOneWidget);
  });

  testWidgets('My requests opens details with timeline and conversation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildMyRequestsTestApp());

    await tester.tap(find.text('ASKY-2048'));
    await tester.pumpAndSettle();

    expect(find.text('Détail de la demande'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Demande envoyée'), findsOneWidget);
    expect(find.text('Demande reçue'), findsOneWidget);
    expect(find.text('En cours de traitement'), findsOneWidget);
    expect(find.text('Échanges'), findsOneWidget);
    expect(find.text('BG-ASKY-20481'), findsWidgets);
    expect(find.text('Agent ASKY'), findsOneWidget);
  });

  testWidgets('My requests adds local message on open request', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildMyRequestsTestApp());

    await tester.tap(find.text('ASKY-2048'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('support-reply-field')));
    await tester.enterText(
      find.byKey(const Key('support-reply-field')),
      'Merci pour le suivi.',
    );
    await tester.tap(find.byKey(const Key('support-reply-send-button')));
    await tester.pumpAndSettle();

    expect(find.text('Merci pour le suivi.'), findsOneWidget);
    expect(find.text('Maintenant'), findsOneWidget);
  });

  testWidgets('My requests prevents replies on closed request', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildMyRequestsTestApp());

    await tester.ensureVisible(find.text('ASKY-1942'));
    await tester.tap(find.text('ASKY-1942'));
    await tester.pumpAndSettle();

    expect(find.text('Cette demande est clôturée.'), findsOneWidget);
    expect(find.byKey(const Key('support-reply-field')), findsNothing);
  });

  testWidgets('My requests navigates to support, baggage and trip details', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildMyRequestsTestApp());

    await tester.tap(find.byKey(const Key('my-requests-new-button')));
    await tester.pumpAndSettle();
    expect(find.text('Support route'), findsOneWidget);

    await tester.pumpWidget(_buildMyRequestsTestApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('ASKY-2048'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('request-baggage-button')));
    await tester.tap(find.byKey(const Key('request-baggage-button')));
    await tester.pumpAndSettle();
    expect(find.text('Baggage route'), findsOneWidget);

    await tester.pumpWidget(_buildMyRequestsTestApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('ASKY-2048'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('request-trip-button')));
    await tester.tap(find.byKey(const Key('request-trip-button')));
    await tester.pumpAndSettle();
    expect(find.text('Trip details route'), findsOneWidget);
  });

  testWidgets('My requests supports empty state', (WidgetTester tester) async {
    await tester.pumpWidget(_buildMyRequestsTestApp(showDemoRequests: false));

    expect(find.text('Aucune demande'), findsOneWidget);
    expect(
      find.text('Vous n’avez encore créé aucune demande d’assistance.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Créer une demande'));
    await tester.pumpAndSettle();

    expect(find.text('Support route'), findsOneWidget);
  });

  testWidgets('Profile displays passenger information', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildProfileTestApp());

    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('DA'), findsOneWidget);
    expect(find.text('Diane Amouzou'), findsOneWidget);
    expect(find.text('diane.amouzou@example.com'), findsWidgets);
    expect(find.text('+228 90 00 00 00'), findsOneWidget);
    expect(find.text('Informations personnelles'), findsOneWidget);
    expect(find.text('Togolaise'), findsOneWidget);
  });

  testWidgets('Profile edits passenger data locally', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildProfileTestApp());

    await tester.tap(find.byKey(const Key('profile-edit-button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('profile-first-name-field')),
      'Afi',
    );
    await tester.enterText(
      find.byKey(const Key('profile-phone-field')),
      '+228 91 11 11 11',
    );
    await tester.tap(find.byKey(const Key('profile-save-button')));
    await tester.pumpAndSettle();

    expect(find.text('Afi Amouzou'), findsOneWidget);
    expect(find.text('+228 91 11 11 11'), findsOneWidget);
    expect(find.text('Profil mis à jour.'), findsOneWidget);
  });

  testWidgets('Profile updates travel preferences and notifications', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildProfileTestApp());

    await tester.ensureVisible(find.byKey(const Key('profile-seat-field')));
    await tester.tap(find.byKey(const Key('profile-seat-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Couloir').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('profile-meal-field')));
    await tester.tap(find.byKey(const Key('profile-meal-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Végétarien').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const Key('profile-notifications-switch')),
    );
    await tester.tap(find.byKey(const Key('profile-notifications-switch')));
    await tester.pumpAndSettle();

    expect(find.text('Couloir'), findsOneWidget);
    expect(find.text('Végétarien'), findsOneWidget);
    expect(find.text('Désactivées'), findsWidgets);
  });

  testWidgets('Profile links to loyalty notifications and assistance', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildProfileTestApp());

    await tester.ensureVisible(find.byKey(const Key('profile-loyalty-button')));
    await tester.tap(find.byKey(const Key('profile-loyalty-button')));
    await tester.pumpAndSettle();
    expect(find.text('Loyalty route'), findsOneWidget);

    await tester.pumpWidget(_buildProfileTestApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('profile-notifications-button')),
    );
    await tester.tap(find.byKey(const Key('profile-notifications-button')));
    await tester.pumpAndSettle();
    expect(find.text('Notifications route'), findsOneWidget);

    await tester.pumpWidget(_buildProfileTestApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('profile-support-button')));
    await tester.tap(find.byKey(const Key('profile-support-button')));
    await tester.pumpAndSettle();
    expect(find.text('Support route'), findsOneWidget);

    await tester.pumpWidget(_buildProfileTestApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('profile-my-requests-button')),
    );
    await tester.tap(find.byKey(const Key('profile-my-requests-button')));
    await tester.pumpAndSettle();
    expect(find.text('My requests route'), findsOneWidget);
  });

  testWidgets('Profile document and password actions show snackbars', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildProfileTestApp());

    await tester.ensureVisible(
      find.byKey(const Key('profile-document-add-button')),
    );
    await tester.tap(find.byKey(const Key('profile-document-add-button')));
    await tester.pump();
    expect(find.text('Gestion des documents à venir.'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const Key('profile-password-button')),
    );
    await tester.tap(find.byKey(const Key('profile-password-button')));
    await tester.pump();
    expect(find.text('Modification du mot de passe à venir.'), findsOneWidget);
  });

  testWidgets('Profile logout dialog navigates to login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildProfileTestApp());

    await tester.ensureVisible(find.byKey(const Key('profile-logout-button')));
    await tester.tap(find.byKey(const Key('profile-logout-button')));
    await tester.pumpAndSettle();

    expect(find.text('Se déconnecter ?'), findsOneWidget);
    expect(
      find.text('Voulez-vous vraiment vous déconnecter de votre compte ?'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('profile-confirm-logout-button')));
    await tester.pumpAndSettle();

    expect(find.text('Login route'), findsOneWidget);
  });

  testWidgets('Profile delete account action shows information dialog', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildProfileTestApp());

    await tester.ensureVisible(
      find.byKey(const Key('profile-delete-account-button')),
    );
    await tester.tap(find.byKey(const Key('profile-delete-account-button')));
    await tester.pumpAndSettle();

    expect(find.text('Supprimer mon compte'), findsWidgets);
    expect(
      find.text(
        'Cette fonctionnalité sera disponible avec la gestion sécurisée du compte côté serveur.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Loyalty screen displays ASKY Club profile and miles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildLoyaltyTestApp());

    expect(find.text('ASKY Club'), findsWidgets);
    expect(find.text('Diane Amouzou'), findsOneWidget);
    expect(find.text('ASKY-CLUB-204815'), findsOneWidget);
    expect(find.text('Silver'), findsWidgets);
    expect(find.text('12 450 miles'), findsOneWidget);
    expect(find.text('12 450'), findsWidgets);
    expect(find.text('8 200 / 10 000 miles statut'), findsOneWidget);
    expect(find.text('Gold'), findsWidgets);
    expect(find.text('82 %'), findsOneWidget);
  });

  testWidgets('Loyalty screen displays benefits and activity history', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildLoyaltyTestApp());

    expect(find.text('Mes avantages'), findsOneWidget);
    expect(find.text('Accès à des offres personnalisées'), findsOneWidget);
    expect(find.text('Activité récente'), findsOneWidget);
    expect(find.text('Vol KP 020'), findsOneWidget);
    expect(find.text('+850 miles'), findsOneWidget);
    expect(find.text('À venir'), findsOneWidget);
    expect(find.text('Crédités'), findsNWidgets(3));
  });

  testWidgets('Loyalty activity opens details bottom sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildLoyaltyTestApp());

    await tester.ensureVisible(find.text('Vol KP 020'));
    await tester.tap(find.text('Vol KP 020'));
    await tester.pumpAndSettle();

    expect(find.text('Type'), findsOneWidget);
    expect(find.text('KP 020'), findsOneWidget);
    expect(find.text('Trajet'), findsOneWidget);
    expect(find.text('Lomé → Accra'), findsWidgets);
  });

  testWidgets('Loyalty use miles shows snackbar and my trips navigates', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildLoyaltyTestApp());

    await tester.ensureVisible(
      find.byKey(const Key('loyalty-use-miles-button')),
    );
    await tester.tap(find.byKey(const Key('loyalty-use-miles-button')));
    await tester.pump();
    expect(find.text('Utilisation des miles à venir.'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const Key('loyalty-my-trips-button')),
    );
    await tester.tap(find.byKey(const Key('loyalty-my-trips-button')));
    await tester.pumpAndSettle();

    expect(find.text('My trips route'), findsOneWidget);
  });

  testWidgets('Loyalty screen supports unlinked account state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildLoyaltyTestApp(hasLoyaltyAccount: false));

    expect(
      find.text('Votre compte ASKY Club n’est pas encore lié.'),
      findsOneWidget,
    );
    expect(find.text('Lier mon compte'), findsOneWidget);

    await tester.tap(find.byKey(const Key('loyalty-link-account-button')));
    await tester.pump();

    expect(find.text('Liaison ASKY Club à venir.'), findsOneWidget);
  });

  testWidgets(
    'Notifications screen displays demo notifications and unread count',
    (WidgetTester tester) async {
      await tester.pumpWidget(_buildNotificationsTestApp());

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('2 non lues'), findsOneWidget);
      expect(find.text('Votre vol est à l’heure'), findsOneWidget);
      expect(find.text('Enregistrement bientôt disponible'), findsOneWidget);
      expect(find.text('Vérifiez vos documents'), findsOneWidget);
      expect(find.text('Préparez vos bagages'), findsOneWidget);
      expect(find.text('Réservation confirmée'), findsOneWidget);
      expect(find.text('Besoin d’aide ?'), findsOneWidget);
    },
  );

  testWidgets('Notifications screen marks one notification as read', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildNotificationsTestApp());

    await tester.tap(find.text('Votre vol est à l’heure'));
    await tester.pumpAndSettle();

    expect(find.text('1 non lue'), findsOneWidget);
    expect(find.text('2 non lues'), findsNothing);
  });

  testWidgets('Notifications screen marks all notifications as read', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildNotificationsTestApp());

    await tester.tap(find.text('Tout lire'));
    await tester.pumpAndSettle();

    expect(find.text('0 non lues'), findsOneWidget);
    expect(find.text('Tout lire'), findsNothing);
  });

  testWidgets(
    'Notifications screen filters flight preparation and assistance items',
    (WidgetTester tester) async {
      await tester.pumpWidget(_buildNotificationsTestApp());

      await tester.tap(find.text('Vol'));
      await tester.pumpAndSettle();
      expect(find.text('Votre vol est à l’heure'), findsOneWidget);
      expect(find.text('Réservation confirmée'), findsOneWidget);
      expect(find.text('Vérifiez vos documents'), findsNothing);

      await tester.tap(find.text('Préparation'));
      await tester.pumpAndSettle();
      expect(find.text('Enregistrement bientôt disponible'), findsOneWidget);
      expect(find.text('Vérifiez vos documents'), findsOneWidget);
      expect(find.text('Préparez vos bagages'), findsOneWidget);
      expect(find.text('Votre vol est à l’heure'), findsNothing);
      expect(find.text('Besoin d’aide ?'), findsNothing);

      await tester.tap(find.text('Assistance'));
      await tester.pumpAndSettle();
      expect(find.text('Besoin d’aide ?'), findsOneWidget);
      expect(find.text('Votre vol est à l’heure'), findsNothing);
    },
  );

  testWidgets('Notifications screen navigates from notification actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildNotificationsTestApp());

    await tester.tap(find.text('Voir le vol'));
    await tester.pumpAndSettle();
    expect(find.text('Flight status route'), findsOneWidget);

    await tester.pumpWidget(_buildNotificationsTestApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Voir mes bagages'));
    await tester.tap(find.text('Voir mes bagages'));
    await tester.pumpAndSettle();
    expect(find.text('Baggage route'), findsOneWidget);

    await tester.pumpWidget(_buildNotificationsTestApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Voir ma checklist'));
    await tester.tap(find.text('Voir ma checklist'));
    await tester.pumpAndSettle();
    expect(find.text('Trip checklist route'), findsOneWidget);

    await tester.pumpWidget(_buildNotificationsTestApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Voir mon voyage'));
    await tester.tap(find.text('Voir mon voyage'));
    await tester.pumpAndSettle();
    expect(find.text('Trip details route'), findsOneWidget);

    await tester.pumpWidget(_buildNotificationsTestApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Demander à l’assistant'));
    await tester.tap(find.text('Demander à l’assistant'));
    await tester.pumpAndSettle();
    expect(find.text('Assistant route'), findsOneWidget);
  });

  testWidgets('Notifications screen shows empty state without notifications', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildNotificationsTestApp(showDemoNotifications: false),
    );

    expect(find.text('Aucune notification'), findsOneWidget);
    expect(
      find.text('Vos alertes de voyage apparaîtront ici.'),
      findsOneWidget,
    );
  });
}

Widget _buildLoginTestApp() {
  return MaterialApp(
    home: const LoginScreen(),
    routes: {
      AppRoutes.register: (_) => const Scaffold(body: Text('Register route')),
      AppRoutes.forgotPassword: (_) =>
          const Scaffold(body: Text('Forgot password route')),
      AppRoutes.dashboard: (_) => const Scaffold(body: Text('Dashboard route')),
    },
  );
}

Widget _buildRegisterTestApp() {
  return MaterialApp(
    home: const RegisterScreen(),
    routes: {
      AppRoutes.login: (_) => const Scaffold(body: Text('Login route')),
      AppRoutes.dashboard: (_) => const Scaffold(body: Text('Dashboard route')),
    },
  );
}

Widget _buildForgotPasswordTestApp() {
  return MaterialApp(
    home: const ForgotPasswordScreen(),
    routes: {AppRoutes.login: (_) => const Scaffold(body: Text('Login route'))},
  );
}

Widget _buildDashboardTestApp({bool showDemoTrip = true}) {
  return MaterialApp(
    home: DashboardScreen(showDemoTrip: showDemoTrip),
    routes: {
      AppRoutes.myTrips: (_) => const Scaffold(body: Text('My trips route')),
      AppRoutes.tripDetails: (_) =>
          const Scaffold(body: Text('Trip details route')),
      AppRoutes.tripChecklist: (_) =>
          const Scaffold(body: Text('Trip checklist route')),
      AppRoutes.flightStatus: (_) =>
          const Scaffold(body: Text('Flight status route')),
      AppRoutes.assistant: (_) => const Scaffold(body: Text('Assistant route')),
      AppRoutes.baggage: (_) => const Scaffold(body: Text('Baggage route')),
      AppRoutes.notifications: (_) =>
          const Scaffold(body: Text('Notifications route')),
      AppRoutes.searchFlight: (_) =>
          const Scaffold(body: Text('Search flight route')),
    },
  );
}

Widget _buildMyTripsTestApp({bool showDemoTrips = true}) {
  return MaterialApp(
    home: MyTripsScreen(showDemoTrips: showDemoTrips),
    routes: {
      AppRoutes.tripDetails: (_) =>
          const Scaffold(body: Text('Trip details route')),
      AppRoutes.searchFlight: (_) =>
          const Scaffold(body: Text('Search flight route')),
    },
  );
}

Widget _buildTripDetailsTestApp({Map<String, Object?>? arguments}) {
  return MaterialApp(
    key: UniqueKey(),
    onGenerateRoute: (settings) {
      if (settings.name == '/') {
        return MaterialPageRoute<void>(
          settings: RouteSettings(arguments: arguments),
          builder: (_) => const TripDetailsScreen(),
        );
      }

      final routes = <String, WidgetBuilder>{
        AppRoutes.tripChecklist: (_) =>
            const Scaffold(body: Text('Trip checklist route')),
        AppRoutes.baggage: (_) => const Scaffold(body: Text('Baggage route')),
        AppRoutes.assistant: (_) =>
            const Scaffold(body: Text('Assistant route')),
        AppRoutes.notifications: (_) =>
            const Scaffold(body: Text('Notifications route')),
      };

      return MaterialPageRoute<void>(
        settings: settings,
        builder: routes[settings.name] ?? (_) => const SizedBox.shrink(),
      );
    },
  );
}

Widget _buildTripChecklistTestApp({Map<String, Object?>? arguments}) {
  return MaterialApp(
    key: UniqueKey(),
    onGenerateRoute: (settings) {
      if (settings.name == '/') {
        return MaterialPageRoute<void>(
          settings: RouteSettings(arguments: arguments),
          builder: (_) => const TripChecklistScreen(),
        );
      }

      final routes = <String, WidgetBuilder>{
        AppRoutes.baggage: (_) => const Scaffold(body: Text('Baggage route')),
        AppRoutes.assistant: (_) =>
            const Scaffold(body: Text('Assistant route')),
      };

      return MaterialPageRoute<void>(
        settings: settings,
        builder: routes[settings.name] ?? (_) => const SizedBox.shrink(),
      );
    },
  );
}

Widget _buildBaggageTestApp({
  Map<String, Object?>? arguments,
  bool showCheckedBaggage = true,
}) {
  return MaterialApp(
    key: UniqueKey(),
    onGenerateRoute: (settings) {
      if (settings.name == '/') {
        return MaterialPageRoute<void>(
          settings: RouteSettings(arguments: arguments),
          builder: (_) => BaggageScreen(showCheckedBaggage: showCheckedBaggage),
        );
      }

      final routes = <String, WidgetBuilder>{
        AppRoutes.support: (_) => const Scaffold(body: Text('Support route')),
        AppRoutes.assistant: (_) =>
            const Scaffold(body: Text('Assistant route')),
      };

      return MaterialPageRoute<void>(
        settings: settings,
        builder: routes[settings.name] ?? (_) => const SizedBox.shrink(),
      );
    },
  );
}

Widget _buildSupportTestApp({Map<String, Object?>? arguments}) {
  return MaterialApp(
    key: UniqueKey(),
    onGenerateRoute: (settings) {
      if (settings.name == '/') {
        return MaterialPageRoute<void>(
          settings: RouteSettings(arguments: arguments),
          builder: (_) => const SupportScreen(),
        );
      }

      final routes = <String, WidgetBuilder>{
        AppRoutes.myRequests: (_) =>
            const Scaffold(body: Text('My requests route')),
        AppRoutes.tripDetails: (_) =>
            const Scaffold(body: Text('Trip details route')),
        AppRoutes.dashboard: (_) =>
            const Scaffold(body: Text('Dashboard route')),
      };

      return MaterialPageRoute<void>(
        settings: settings,
        builder: routes[settings.name] ?? (_) => const SizedBox.shrink(),
      );
    },
  );
}

Widget _buildMyRequestsTestApp({bool showDemoRequests = true}) {
  return MaterialApp(
    key: UniqueKey(),
    home: MyRequestsScreen(showDemoRequests: showDemoRequests),
    routes: {
      AppRoutes.support: (_) => const Scaffold(body: Text('Support route')),
      AppRoutes.baggage: (_) => const Scaffold(body: Text('Baggage route')),
      AppRoutes.tripDetails: (_) =>
          const Scaffold(body: Text('Trip details route')),
      AppRoutes.assistant: (_) => const Scaffold(body: Text('Assistant route')),
    },
  );
}

Widget _buildProfileTestApp() {
  return MaterialApp(
    key: UniqueKey(),
    home: const ProfileScreen(),
    routes: {
      AppRoutes.loyalty: (_) => const Scaffold(body: Text('Loyalty route')),
      AppRoutes.notifications: (_) =>
          const Scaffold(body: Text('Notifications route')),
      AppRoutes.support: (_) => const Scaffold(body: Text('Support route')),
      AppRoutes.myRequests: (_) =>
          const Scaffold(body: Text('My requests route')),
      AppRoutes.login: (_) => const Scaffold(body: Text('Login route')),
    },
  );
}

Widget _buildLoyaltyTestApp({bool hasLoyaltyAccount = true}) {
  return MaterialApp(
    key: UniqueKey(),
    home: LoyaltyScreen(hasLoyaltyAccount: hasLoyaltyAccount),
    routes: {
      AppRoutes.myTrips: (_) => const Scaffold(body: Text('My trips route')),
    },
  );
}

Widget _buildNotificationsTestApp({bool showDemoNotifications = true}) {
  return MaterialApp(
    key: UniqueKey(),
    home: NotificationsScreen(showDemoNotifications: showDemoNotifications),
    routes: {
      AppRoutes.flightStatus: (_) =>
          const Scaffold(body: Text('Flight status route')),
      AppRoutes.baggage: (_) => const Scaffold(body: Text('Baggage route')),
      AppRoutes.tripChecklist: (_) =>
          const Scaffold(body: Text('Trip checklist route')),
      AppRoutes.tripDetails: (_) =>
          const Scaffold(body: Text('Trip details route')),
      AppRoutes.assistant: (_) => const Scaffold(body: Text('Assistant route')),
    },
  );
}
