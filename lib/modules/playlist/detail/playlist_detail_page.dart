import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/navigation/app_navigate.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../library/utils/library_playback.dart';
import '../../library/widgets/library_song_row.dart';
import '../../library/widgets/song_empty_state.dart';
import '../../player/app_player_shell.dart';
import '../../player/show_song_options.dart';
import '../../player/song_options_config.dart';
import '../widgets/confirm_delete_playlist_dialog.dart';
import '../widgets/playlist_cover_card.dart';
import '../widgets/playlist_menu_sheet.dart';
import 'playlist_detail_controller.dart';

class PlaylistDetailPage extends GetView<PlaylistDetailController> {
  const PlaylistDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final songList = controller.songs.toList();
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 10, 0),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: AppNavigate.back,
                        child: const AppIcon(AppAssets.icBackThin, size: 25, color: AppColors.black),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => PlaylistMenuSheet.show(
                          context,
                          onAddSongs: controller.openAddSongs,
                          onEdit: controller.openEdit,
                          onDelete: () async {
                            final ok = await showConfirmDeletePlaylistDialog(context);
                            if (ok == true) await controller.deletePlaylist();
                          },
                        ),
                        child: const AppIcon(AppAssets.icMenu, size: 25, color: AppColors.black),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    PlaylistCoverCard(coverUrl: controller.coverUrl()),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        controller.title(l10n),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      controller.metaText(l10n),
                      style: const TextStyle(fontSize: 12, color: AppColors.txtHint),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              if (songList.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: SongEmptyState(
                    title: l10n.playlist_songs_empty,
                    subtitle: '',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final song = songList[i];
                        return LibrarySongRow(
                          song: song,
                          onTap: () => playVisibleSongList(songList, song.id),
                          onMore: () => showSongOptions(
                            context,
                            song,
                            config: SongOptionsConfig.playlistDetail(
                              onRemoveFromPlaylist: () => controller.removeSong(song.id),
                            ),
                          ),
                        );
                      },
                      childCount: songList.length,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: SizedBox(height: AppPlayerShell.scrollListBottomInset),
              ),
            ],
          );
        }),
      ),
    );
  }
}
