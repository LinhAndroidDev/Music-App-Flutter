import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';

enum AppToastCategory {
  general,
  playlist,
  favourite,
  artist,
  auth,
  playback,
  player,
}

/// Top snackbar with a visible title (ServiceMusic-style feedback, easier to scan).
void showAppToast(
  String message, {
  AppToastCategory category = AppToastCategory.general,
  String? title,
  Duration duration = const Duration(seconds: 3),
}) {
  final ctx = Get.context;
  if (ctx == null || message.trim().isEmpty) return;

  final l10n = ctx.l10n;
  final resolvedTitle = title ?? _titleForCategory(l10n, category);
  // GetX snackbar already applies SafeArea top inset — do not add padding.top again.
  const horizontal = 16.0;
  const gapBelowStatusBar = 4.0;

  Get.snackbar(
    resolvedTitle,
    message,
    snackPosition: SnackPosition.TOP,
    margin: const EdgeInsets.fromLTRB(horizontal, gapBelowStatusBar, horizontal, 0),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    backgroundColor: AppColors.white,
    borderRadius: 12,
    borderColor: const Color(0xFFE8E8E8),
    borderWidth: 1,
    boxShadows: const [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
    duration: duration,
    isDismissible: true,
    dismissDirection: DismissDirection.up,
    forwardAnimationCurve: Curves.easeOutCubic,
    reverseAnimationCurve: Curves.easeInCubic,
    titleText: Text(
      resolvedTitle,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.textBlack,
      ),
    ),
    messageText: Text(
      message,
      style: const TextStyle(
        fontSize: 14,
        height: 1.35,
        color: AppColors.txtHint,
      ),
    ),
  );
}

String _titleForCategory(AppLocalizations l10n, AppToastCategory category) {
  return switch (category) {
    AppToastCategory.general => l10n.toast_title_general,
    AppToastCategory.playlist => l10n.toast_title_playlist,
    AppToastCategory.favourite => l10n.toast_title_favourite,
    AppToastCategory.artist => l10n.toast_title_artist,
    AppToastCategory.auth => l10n.toast_title_auth,
    AppToastCategory.playback => l10n.toast_title_playback,
    AppToastCategory.player => l10n.toast_title_player,
  };
}
