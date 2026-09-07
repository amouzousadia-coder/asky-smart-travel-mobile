import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({this.showAppBar = true, super.key});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return AppPlaceholderScreen(title: 'Profil', showAppBar: showAppBar);
  }
}
