import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            iconSize: 22,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.flight_takeoff_outlined),
                activeIcon: Icon(Icons.flight_takeoff),
                label: 'Réserver',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.work_outline),
                activeIcon: Icon(Icons.work),
                label: 'Mon voyage',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_outlined),
                activeIcon: Icon(Icons.menu),
                label: 'Plus',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
