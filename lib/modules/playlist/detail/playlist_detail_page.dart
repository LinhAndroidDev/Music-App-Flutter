import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/navigation/app_navigate.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../library/utils/library_playback.dart';
import '../../library/widgets/library_song_row.dart';
import '../../library/widgets/song_empty_state.dart';
import '../../player/app_player_shell.dart';
import '../../player/show_song_options.dart';
import '../../player/song_options_config.dart';
import '../widgets/confirm_delete_playlist_dialog.dart';
import '../widgets/playlist_menu_sheet.dart';
import '../widgets/resizable_header_scroll.dart';
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
          final heroCoverUrl = controller.initialCoverUrl.isNotEmpty
              ? controller.initialCoverUrl
              : controller.coverUrl();
          return ResizableHeaderScroll(
            playlistId: controller.playlistId,
            coverUrl: heroCoverUrl,
            title: controller.title(l10n),
            meta: controller.metaText(l10n),
            onBack: AppNavigate.back,
            onMenu: () => PlaylistMenuSheet.show(
              context,
              onAddSongs: controller.openAddSongs,
              onEdit: controller.openEdit,
              onDelete: () async {
                final ok = await showConfirmDeletePlaylistDialog(context);
                if (ok == true) await controller.deletePlaylist();
              },
            ),
            slivers: [
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
