import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppDecorations {
  static BoxDecoration whiteCard10({Color? backgroundColor}) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.greyLight, width: 0.8),
    );
  }

  static BoxDecoration libraryShortcutCard() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppColors.greyLight, width: 0.7),
    );
  }
}
