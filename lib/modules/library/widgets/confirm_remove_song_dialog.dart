import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/service_music_dialog.dart';

Future<bool?> showConfirmRemoveSongDialog(BuildContext context, String songTitle) {
  final l10n = context.l10n;
  return ServiceMusicDialog.show<bool>(
    context,
    child: Builder(
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ServiceMusicDialogTitle(songTitle),
          ServiceMusicDialogMessage(l10n.delete_song_from_library_message),
          ServiceMusicDialogPrimaryButton(
            label: l10n.action_delete,
            onTap: () => Navigator.of(ctx).pop(true),
          ),
          ServiceMusicDialogCancelButton(
            label: l10n.playlist_cancel,
            onTap: () => Navigator.of(ctx).pop(false),
          ),
        ],
      ),
    ),
  );
}
