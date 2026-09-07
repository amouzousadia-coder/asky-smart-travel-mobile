import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({this.showAppBar = true, super.key});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return AppPlaceholderScreen(title: 'Accueil', showAppBar: showAppBar);
  }
}
