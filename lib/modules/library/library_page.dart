import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/assets/app_assets.dart';
import '../../core/l10n/l10n.dart';
import '../../core/navigation/app_navigate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/screen_header.dart';
import '../../data/models/user_playlist.dart';
import '../../data/playback/downloaded_song_repository.dart';
import '../../data/services/favourite_song_repository.dart';
import '../../data/services/followed_singer_repository.dart';
import '../../data/services/playlist_repository.dart';
import '../../data/services/recent_history_repository.dart';
import '../player/app_player_shell.dart';
import 'library_controller.dart';
import 'widgets/library_shortcut_card.dart';
import 'widgets/playlist_list_tile.dart';
import 'widgets/recent_see_all_tile.dart';
import 'widgets/recent_song_tile.dart';

class LibraryPage extends GetView<LibraryController> {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final favourites = Get.find<FavouriteSongRepository>();
    final followed = Get.find<FollowedSingerRepository>();
    final downloads = Get.find<DownloadedSongRepository>();
    final recent = Get.find<RecentHistoryRepository>();
    final playlists = Get.find<PlaylistRepository>();

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: AppPlayerShell.scrollBottomPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ScreenHeader(title: l10n.nav_library),
              ),
              const SizedBox(height: 20),
              Obx(() {
                downloads.completedCount.value;
                final items = _shortcuts(context, favourites, followed);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: items,
                  ),
                );
              }),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  l10n.recent_history_title,
                  style: _sectionTitleStyle,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (recent.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final preview = recent.previewSongs();
                if (preview.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      l10n.recent_history_empty,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.txtHint,
                      ),
                    ),
                  );
                }
                return SizedBox(
                  // Item: 108 art + 6 + title + 2 + singer (~145); extra for text scale.
                  height: 152,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 15),
                    scrollDirection: Axis.horizontal,
                    itemCount: preview.length + (recent.showSeeAll ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (recent.showSeeAll && i == preview.length) {
                        return RecentSeeAllTile(
                          onTap: controller.openRecentHistory,
                        );
                      }
                      return RecentSongTile(
                        song: preview[i],
                        onTap: () => controller.playRecentSong(preview[i]),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.playlist_section_title,
                        style: _sectionTitleStyle,
                      ),
                    ),
                    InkWell(
                      onTap: controller.showCreatePlaylistDialog,
                      child: AppIcon(
                        AppAssets.icAddPlaylist,
                        size: 24,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Obx(() {
                final list = playlists.playlists;
                if (list.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(15, 12, 15, 24),
                    child: Text(
                      l10n.playlist_empty,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.txtHint,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final p = list[i];
                    return PlaylistListTile(
                      playlist: p,
                      metaText: _playlistMeta(l10n, p),
                      onTap: () => AppNavigate.toPlaylistDetail(
                        playlistId: p.id,
                        playlistTitle: p.title,
                        playlistCoverUrl: p.coverUrl,
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  static const _sectionTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  List<Widget> _shortcuts(
    BuildContext context,
    FavouriteSongRepository favourites,
    FollowedSingerRepository followed,
  ) {
    final l10n = context.l10n;
    final data = [
      (AppAssets.favourite, AppColors.bgBlue, l10n.library_item_favourite, favourites.favouriteCount.value),
      (AppAssets.icDownload, AppColors.bgPurple, l10n.downloaded_songs_title, controller.downloadedCount),
      (AppAssets.icArtist, AppColors.bgOrange, l10n.library_item_artists, followed.followedCount.value),
      (AppAssets.icUpload, AppColors.yellowDark, l10n.library_item_upload, 0),
      (AppAssets.icMv, AppColors.bgPurple, l10n.library_item_mv, 0),
    ];
    return List.generate(data.length, (i) {
      final (icon, color, title, count) = data[i];
      return LibraryShortcutCard(
        leadingMargin: i == 0,
        iconAsset: icon,
        iconColor: color,
        title: title,
        count: count,
        onTap: () => controller.onShortcutTap(i),
      );
    });
  }

  String _playlistMeta(dynamic l10n, UserPlaylist p) {
    if (p.isPublic) {
      return l10n.playlist_meta_public(p.songCount);
    }
    return l10n.playlist_meta_private(p.songCount);
  }
}
