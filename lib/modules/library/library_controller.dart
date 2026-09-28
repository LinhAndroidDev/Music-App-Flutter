import 'package:get/get.dart';

import '../../core/base/base_controller.dart';
import '../../core/l10n/l10n.dart';
import '../../core/navigation/app_navigate.dart';
import '../../data/playback/downloaded_song_repository.dart';
import '../../data/models/song.dart';
import '../../data/services/favourite_song_repository.dart';
import '../../data/services/followed_singer_repository.dart';
import '../../data/services/playlist_repository.dart' show PlaylistMutationResult, PlaylistRepository;
import '../../data/services/recent_history_repository.dart';
import '../library/utils/library_playback.dart';
import 'widgets/create_playlist_dialog.dart';

class LibraryController extends BaseController {
  FavouriteSongRepository get _favourites => Get.find<FavouriteSongRepository>();
  FollowedSingerRepository get _followed => Get.find<FollowedSingerRepository>();
  DownloadedSongRepository get _downloads => Get.find<DownloadedSongRepository>();
  PlaylistRepository get _playlists => Get.find<PlaylistRepository>();
  int get favouriteCount => _favourites.favouriteCount.value;
  int get followedCount => _followed.followedCount.value;
  int get downloadedCount => _downloads.completedCount.value;

  void onShortcutTap(int index) {
    switch (index) {
      case 0:
        AppNavigate.toFavouriteSong();
      case 1:
        AppNavigate.toDownloadedSongs();
      case 2:
        AppNavigate.toFollowedSingers();
      case 3:
      case 4:
        Get.snackbar('', 'Tính năng sắp có', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void openRecentHistory() => AppNavigate.toRecentHistory();

  Future<void> playRecentSong(Song song) async {
    final recent = Get.find<RecentHistoryRepository>();
    final list = recent.recentSongs.toList();
    if (list.isEmpty) return;
    await playVisibleSongList(list, song.id);
  }

  Future<void> showCreatePlaylistDialog() async {
    final l10n = Get.context?.l10n;
    if (l10n == null) return;

    final result = await Get.dialog<CreatePlaylistResult>(
      const CreatePlaylistDialog(),
    );
    if (result == null) return;

    final mutation = await _playlists.createPlaylist(
      title: result.title,
      isPublic: result.isPublic,
    );
    switch (mutation) {
      case PlaylistMutationResult.success:
        Get.snackbar('', l10n.playlist_created, snackPosition: SnackPosition.BOTTOM);
      case PlaylistMutationResult.requiresLogin:
        Get.snackbar('', l10n.playlist_login_required, snackPosition: SnackPosition.BOTTOM);
      case PlaylistMutationResult.failure:
        Get.snackbar('', l10n.playlist_operation_failed, snackPosition: SnackPosition.BOTTOM);
      default:
        break;
    }
  }
}
