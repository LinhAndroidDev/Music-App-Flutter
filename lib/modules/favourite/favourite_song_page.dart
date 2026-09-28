import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../player/app_player_shell.dart';
import '../library/widgets/confirm_remove_song_dialog.dart';
import '../library/widgets/library_subpage_header.dart';
import '../library/widgets/library_song_row.dart';
import '../library/widgets/song_arrangement_sheet.dart';
import '../library/widgets/song_empty_state.dart';
import 'favourite_song_controller.dart';

class FavouriteSongPage extends GetView<FavouriteSongController> {
  const FavouriteSongPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Obx(() {
          final songs = controller.sortedSongs;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: LibrarySubpageHeader(
                  title: l10n.favourite_songs_title,
                  showDownloadAction: true,
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Text(
                      l10n.favourite_songs_title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.favourite_songs_count(songs.length),
                      style: const TextStyle(fontSize: 12, color: AppColors.txtHint),
                    ),
                    const SizedBox(height: 30),
                    if (songs.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Material(
                          color: AppColors.purple1,
                          borderRadius: BorderRadius.circular(25),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: controller.playShuffle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 7),
                              child: Text(
                                l10n.play_shuffle,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (songs.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            const Spacer(),
                            InkWell(
                              onTap: () async {
                                final picked = await showSongArrangementSheet(
                                  context,
                                  controller.arrangement.value,
                                );
                                if (picked != null) {
                                  await controller.changeArrangement(picked);
                                }
                              },
                              child: Row(
                                children: [
                                  Obx(
                                    () => Text(
                                      controller.arrangementLabel(l10n),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.txtHint,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down, color: AppColors.txtHint),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (songs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: SongEmptyState(
                    title: l10n.favourite_empty_title,
                    subtitle: l10n.favourite_empty_subtitle,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 10, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = songs[index];
                        return LibrarySongRow(
                          song: song,
                          showUnfavourite: true,
                          onTap: () => controller.playSong(song),
                          onUnfavourite: () async {
                            final ok = await showConfirmRemoveSongDialog(context, song.title);
                            if (ok == true) await controller.removeFavourite(song);
                          },
                        );
                      },
                      childCount: songs.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppPlayerShell.scrollListBottomInset),
              ),
            ],
          );
        }),
      ),
    );
  }
}
