import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../library/widgets/library_subpage_header.dart';
import '../library/widgets/library_song_row.dart';
import '../library/widgets/song_empty_state.dart';
import '../player/show_song_options.dart';
import 'downloaded_songs_controller.dart';

class DownloadedSongsPage extends GetView<DownloadedSongsController> {
  const DownloadedSongsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Obx(() {
          final songs = controller.songs;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: LibrarySubpageHeader(title: l10n.downloaded_songs_title)),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Text(
                      l10n.downloaded_songs_title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.downloaded_songs_count(songs.length),
                      style: const TextStyle(fontSize: 12, color: AppColors.txtHint),
                    ),
                  ],
                ),
              ),
              if (songs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: SongEmptyState(
                    title: l10n.downloaded_songs_empty,
                    subtitle: l10n.network_offline_subtitle,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 10, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = songs[index];
                        return LibrarySongRow(
                          song: song,
                          onTap: () => controller.playSong(song),
                          onMore: () => showSongOptions(context, song),
                        );
                      },
                      childCount: songs.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(
                child: const SizedBox(height: 24),
              ),
            ],
          );
        }),
      ),
    );
  }
}
