import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_screen.dart';

class SearchFlightScreen extends StatelessWidget {
  const SearchFlightScreen({this.showAppBar = true, super.key});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return AppPlaceholderScreen(
      title: 'Rechercher un vol',
      showAppBar: showAppBar,
    );
  }
}
