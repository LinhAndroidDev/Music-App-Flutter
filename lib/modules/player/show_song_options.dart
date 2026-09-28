import 'package:flutter/material.dart';

import '../../data/models/song.dart';
import 'song_options_config.dart';
import 'widgets/song_options_sheet.dart';

void showSongOptions(
  BuildContext context,
  Song song, {
  SongOptionsConfig config = SongOptionsConfig.list,
}) {
  SongOptionsSheet.show(context, song: song, config: config);
}
