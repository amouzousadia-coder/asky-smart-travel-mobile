import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_screen.dart';

class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({this.showAppBar = true, super.key});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return AppPlaceholderScreen(title: 'Mes voyages', showAppBar: showAppBar);
  }
}
