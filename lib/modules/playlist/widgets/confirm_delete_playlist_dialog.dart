import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/service_music_dialog.dart';

Future<bool?> showConfirmDeletePlaylistDialog(BuildContext context) {
  final l10n = context.l10n;
  return ServiceMusicDialog.show<bool>(
    context,
    child: Builder(
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ServiceMusicDialogTitle(l10n.playlist_delete_title),
          ServiceMusicDialogMessage(l10n.playlist_delete_message),
          ServiceMusicDialogPrimaryButton(
            label: l10n.playlist_delete_confirm,
            onTap: () => Navigator.pop(ctx, true),
          ),
          ServiceMusicDialogCancelButton(
            label: l10n.playlist_cancel,
            onTap: () => Navigator.pop(ctx, false),
          ),
        ],
      ),
    ),
  );
}
