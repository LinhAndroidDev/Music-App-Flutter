import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/song_arrangement.dart';

Future<SongArrangement?> showSongArrangementSheet(
  BuildContext context,
  SongArrangement current,
) {
  return showModalBottomSheet<SongArrangement>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final l10n = ctx.l10n;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.arrange_title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ...SongArrangement.values.map(
              (mode) => RadioListTile<SongArrangement>(
                value: mode,
                groupValue: current,
                onChanged: (v) => Navigator.pop(ctx, v),
                title: Text(_label(l10n, mode)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

String _label(dynamic l10n, SongArrangement mode) {
  return switch (mode) {
    SongArrangement.newest => l10n.arrange_newest,
    SongArrangement.oldest => l10n.arrange_oldest,
    SongArrangement.bySongName => l10n.arrange_by_song_name,
    SongArrangement.byArtistName => l10n.arrange_by_artist_name,
  };
}
