import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      body: _tabs[_currentIndex],
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
