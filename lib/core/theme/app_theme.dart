import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Light theme aligned with ServiceMusic defaults (`background`, `purple_1`, text colors).
abstract final class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: AppColors.purple1,
      onPrimary: AppColors.textWhite,
      secondary: AppColors.bgPurple,
      surface: AppColors.background,
      onSurface: AppColors.textBlack,
      error: AppColors.red,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textBlack,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      hintColor: AppColors.txtHint,
      dividerColor: AppColors.greyLight,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textBlack),
        bodyMedium: TextStyle(color: AppColors.textBlack),
        bodySmall: TextStyle(color: AppColors.txtHint),
      ),
    );
  }
}
