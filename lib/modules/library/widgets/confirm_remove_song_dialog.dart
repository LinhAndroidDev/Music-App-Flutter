import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';

Future<bool?> showConfirmRemoveSongDialog(BuildContext context, String songTitle) {
  final l10n = context.l10n;
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(songTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      content: Text(l10n.delete_song_from_library_message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.action_cancel)),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            l10n.action_delete,
            style: const TextStyle(color: AppColors.bgPink),
          ),
        ),
      ],
    ),
  );
}
