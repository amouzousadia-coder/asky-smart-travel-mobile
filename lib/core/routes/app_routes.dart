import 'package:flutter/material.dart';

import '../../screens/assistant/assistant_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/baggage/baggage_screen.dart';
import '../../screens/flights/destinations_screen.dart';
import '../../screens/flights/flight_details_screen.dart';
import '../../screens/flights/flight_results_screen.dart';
import '../../screens/flights/flight_status_screen.dart';
import '../../screens/flights/search_flight_screen.dart';
import '../../screens/home/dashboard_screen.dart';
import '../../screens/home/main_navigation_screen.dart';
import '../../screens/loyalty/loyalty_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/support/my_requests_screen.dart';
import '../../screens/support/support_screen.dart';
import '../../screens/trips/my_trips_screen.dart';
import '../../screens/trips/trip_checklist_screen.dart';
import '../../screens/trips/trip_details_screen.dart';
import '../widgets/placeholder_screen.dart';

abstract final class AppRoutes {
  static const String home = '/';
  static const String searchFlight = '/search-flight';
  static const String flightResults = '/flight-results';
  static const String flightDetails = '/flight-details';
  static const String flightStatus = '/flight-status';
  static const String destinations = '/destinations';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String myTrips = '/my-trips';
  static const String tripDetails = '/trip-details';
  static const String tripChecklist = '/trip-checklist';
  static const String assistant = '/assistant';
  static const String notifications = '/notifications';
  static const String baggage = '/baggage';
  static const String support = '/support';
  static const String myRequests = '/my-requests';
  static const String profile = '/profile';
  static const String loyalty = '/loyalty';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (_) => const MainNavigationScreen(),
      searchFlight: (_) => const SearchFlightScreen(),
      flightResults: (_) => const FlightResultsScreen(),
      flightDetails: (_) => const FlightDetailsScreen(),
      flightStatus: (_) => const FlightStatusScreen(),
      destinations: (_) => const DestinationsScreen(),
      login: (_) => const LoginScreen(),
      register: (_) => const RegisterScreen(),
      forgotPassword: (_) => const ForgotPasswordScreen(),
      dashboard: (_) => const DashboardScreen(),
      myTrips: (_) => const MyTripsScreen(),
      tripDetails: (_) => const TripDetailsScreen(),
      tripChecklist: (_) => const TripChecklistScreen(),
      assistant: (_) => const AssistantScreen(),
      notifications: (_) => const NotificationsScreen(),
      baggage: (_) => const BaggageScreen(),
      support: (_) => const SupportScreen(),
      myRequests: (_) => const MyRequestsScreen(),
      profile: (_) => const ProfileScreen(),
      loyalty: (_) => const LoyaltyScreen(),
    };
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => const AppPlaceholderScreen(title: 'Page introuvable'),
    );
  }
}
