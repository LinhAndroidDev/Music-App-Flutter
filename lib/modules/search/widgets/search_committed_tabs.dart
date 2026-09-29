import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/firestore_song.dart';
import '../../../data/models/song.dart';
import '../../library/widgets/library_song_row.dart';
import 'search_singer_row.dart';

class SearchCommittedTabs extends StatelessWidget {
  const SearchCommittedTabs({
    super.key,
    required this.songs,
    required this.singers,
    required this.bottomPadding,
    required this.onSongTap,
    required this.onSongMore,
    required this.onSingerTap,
  });

  final List<Song> songs;
  final List<FirestoreSinger> singers;
  final double bottomPadding;
  final ValueChanged<Song> onSongTap;
  final ValueChanged<Song> onSongMore;
  final ValueChanged<FirestoreSinger> onSingerTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            labelColor: AppColors.purple1,
            unselectedLabelColor: AppColors.txtHint,
            indicatorColor: AppColors.purple1,
            dividerColor: AppColors.greyLight,
            padding: const EdgeInsets.symmetric(horizontal: 11),
            tabs: [
              Tab(text: l10n.search_section_songs),
              Tab(text: l10n.search_section_artists),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _SongTab(
                  songs: songs,
                  emptyText: l10n.search_songs_empty,
                  bottomPadding: bottomPadding,
                  onSongTap: onSongTap,
                  onSongMore: onSongMore,
                ),
                _SingerTab(
                  singers: singers,
                  emptyText: l10n.search_singers_empty,
                  bottomPadding: bottomPadding,
                  onSingerTap: onSingerTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SongTab extends StatelessWidget {
  const _SongTab({
    required this.songs,
    required this.emptyText,
    required this.bottomPadding,
    required this.onSongTap,
    required this.onSongMore,
  });

  final List<Song> songs;
  final String emptyText;
  final double bottomPadding;
  final ValueChanged<Song> onSongTap;
  final ValueChanged<Song> onSongMore;

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return Center(
        child: Text(emptyText, style: const TextStyle(color: AppColors.txtHint, fontSize: 14)),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(15, 8, 15, bottomPadding),
      itemCount: songs.length,
      itemBuilder: (_, i) {
        final song = songs[i];
        return LibrarySongRow(
          song: song,
          onTap: () => onSongTap(song),
          onMore: () => onSongMore(song),
        );
      },
    );
  }
}

class _SingerTab extends StatelessWidget {
  const _SingerTab({
    required this.singers,
    required this.emptyText,
    required this.bottomPadding,
    required this.onSingerTap,
  });

  final List<FirestoreSinger> singers;
  final String emptyText;
  final double bottomPadding;
  final ValueChanged<FirestoreSinger> onSingerTap;

  @override
  Widget build(BuildContext context) {
    if (singers.isEmpty) {
      return Center(
        child: Text(emptyText, style: const TextStyle(color: AppColors.txtHint, fontSize: 14)),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(15, 8, 15, bottomPadding),
      itemCount: singers.length,
      itemBuilder: (_, i) {
        final singer = singers[i];
        return SearchSingerRow(
          singer: singer,
          onTap: () => onSingerTap(singer),
        );
      },
    );
  }
}
