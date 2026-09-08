import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../flights/search_flight_screen.dart';
import '../profile/profile_screen.dart';
import '../trips/my_trips_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  static const List<Widget> _tabs = [
    HomeScreen(showAppBar: false),
    SearchFlightScreen(showAppBar: false),
    MyTripsScreen(showAppBar: false),
    ProfileScreen(showAppBar: false),
  ];

  static const List<String> _titles = [
    'Accueil',
    'Rechercher un vol',
    'Mes voyages',
    'Plus',
  ];

  @override
  Widget build(BuildContext context) {
    final isHomeTab = _currentIndex == 0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_titles[_currentIndex]),
        actions: isHomeTab
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Text(
                      'FR',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: _tabs[_currentIndex],
      floatingActionButton: isHomeTab
          ? FloatingActionButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.assistant),
              child: const Icon(Icons.auto_awesome),
            )
          : null,
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
