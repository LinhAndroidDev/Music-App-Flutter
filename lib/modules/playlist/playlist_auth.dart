import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/l10n/l10n.dart';
import '../../core/widgets/service_music_dialog.dart';
import '../../data/services/auth_repository.dart';

/// Returns true when the user is signed in (or sign-in succeeded).
Future<bool> ensureSignedInForPlaylist(BuildContext context) async {
  final auth = Get.find<AuthRepository>();
  if (auth.isSignedIn) return true;

  final l10n = context.l10n;
  final proceed = await ServiceMusicDialog.show<bool>(
    context,
    child: Builder(
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ServiceMusicDialogTitle(l10n.playlist_login_title),
          ServiceMusicDialogMessage(l10n.playlist_login_message),
          ServiceMusicDialogPrimaryButton(
            label: l10n.favourite_login_action,
            onTap: () => Navigator.pop(ctx, true),
          ),
          ServiceMusicDialogCancelButton(
            label: l10n.favourite_login_later,
            onTap: () => Navigator.pop(ctx, false),
          ),
        ],
      ),
    ),
  );
  if (proceed != true) return false;

  final result = await auth.signInWithGoogle();
  return result.status == GoogleSignInStatus.success;
}
