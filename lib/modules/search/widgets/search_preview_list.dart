import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/firestore_song.dart';
import '../../../data/models/song.dart';
import '../../library/widgets/library_song_row.dart';
import 'search_singer_row.dart';

class SearchPreviewList extends StatelessWidget {
  const SearchPreviewList({
    super.key,
    required this.relatedNames,
    required this.songs,
    required this.singers,
    required this.bottomPadding,
    required this.onRelatedNameTap,
    required this.onSongTap,
    required this.onSongMore,
    required this.onSingerTap,
  });

  final List<String> relatedNames;
  final List<Song> songs;
  final List<FirestoreSinger> singers;
  final double bottomPadding;
  final ValueChanged<String> onRelatedNameTap;
  final ValueChanged<Song> onSongTap;
  final ValueChanged<Song> onSongMore;
  final ValueChanged<FirestoreSinger> onSingerTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = <Widget>[];

    for (final name in relatedNames) {
      rows.add(
        InkWell(
          onTap: () => onRelatedNameTap(name),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              name,
              style: const TextStyle(fontSize: 15, color: AppColors.textBlack),
            ),
          ),
        ),
      );
    }

    if (songs.isNotEmpty) {
      rows.add(_sectionHeader(l10n.search_section_songs));
      for (final song in songs) {
        rows.add(
          LibrarySongRow(
            song: song,
            onTap: () => onSongTap(song),
            onMore: () => onSongMore(song),
          ),
        );
      }
    }

    if (singers.isNotEmpty) {
      rows.add(_sectionHeader(l10n.search_section_artists));
      for (final singer in singers) {
        rows.add(
          SearchSingerRow(
            singer: singer,
            onTap: () => onSingerTap(singer),
          ),
        );
      }
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(15, 8, 15, bottomPadding),
      children: rows,
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textBlack,
        ),
      ),
    );
  }
}
