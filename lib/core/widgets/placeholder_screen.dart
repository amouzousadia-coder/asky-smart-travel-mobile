import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppPlaceholderScreen extends StatelessWidget {
  const AppPlaceholderScreen({
    required this.title,
    this.showAppBar = true,
    super.key,
  });

  final String title;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(title)) : null,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.screenTitle,
            ),
          ),
        ),
      ),
    );
  }
}
