import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

abstract final class AppTextStyles {
  static const TextStyle screenTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle overline = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );
}
