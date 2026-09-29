import 'dart:async';

import 'package:get/get.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/navigation/app_navigate.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/navigation/app_route.dart';
import '../../../data/models/song.dart';
import '../../../data/models/user_playlist.dart';
import '../../../data/services/playlist_repository.dart';
import '../playlist_mutation_ui.dart';

class PlaylistDetailController extends GetxController {
  PlaylistDetailController({PlaylistRepository? playlists})
      : _playlists = playlists ?? Get.find<PlaylistRepository>();

  final PlaylistRepository _playlists;

  final playlistId = Get.parameters[AppRouteParam.playlistId] ?? '';
  final initialTitle = Get.parameters[AppRouteParam.playlistTitle] ?? '';
  final initialCoverUrl = Get.parameters[AppRouteParam.playlistCoverUrl] ?? '';

  final playlist = Rxn<UserPlaylist>();
  final songs = <Song>[].obs;

  StreamSubscription<UserPlaylist?>? _playlistSub;
  StreamSubscription<List<Song>>? _songsSub;

  @override
  void onInit() {
    super.onInit();
    _playlistSub = _playlists.watchPlaylist(playlistId).listen(playlist.call);
    _songsSub = _playlists.watchSongs(playlistId).listen(songs.assignAll);
  }

  @override
  void onClose() {
    _playlistSub?.cancel();
    _songsSub?.cancel();
    super.onClose();
  }

  String title(dynamic l10n) {
    final t = playlist.value?.title;
    if (t != null && t.isNotEmpty) return t;
    if (initialTitle.isNotEmpty) return initialTitle;
    return l10n.playlist_section_title;
  }

  String metaText(dynamic l10n) {
    final p = playlist.value;
    final count = songs.length;
    if (p == null) return l10n.playlist_song_count(count);
    if (p.isPublic) return l10n.playlist_meta_public(count);
    return l10n.playlist_meta_private(count);
  }

  String coverUrl() {
    if (songs.isNotEmpty && songs.first.thumbnailUrl.isNotEmpty) {
      return songs.first.thumbnailUrl;
    }
    final c = playlist.value?.coverUrl;
    if (c != null && c.isNotEmpty) return c;
    return initialCoverUrl;
  }

  void openAddSongs() {
    AppNavigate.toAddPlaylistSongs(playlistId: playlistId);
  }

  void openEdit() {
    AppNavigate.toEditPlaylist(playlistId: playlistId);
  }

  Future<void> deletePlaylist() async {
    final result = await _playlists.deletePlaylist(playlistId);
    if (result == PlaylistMutationResult.success) {
      final l10n = Get.context?.l10n;
      if (l10n != null) {
        showAppToast(l10n.playlist_deleted, category: AppToastCategory.playlist);
      }
      AppNavigate.back();
    } else {
      showPlaylistMutationSnackbar(result);
    }
  }

  Future<void> removeSong(String songId) async {
    final result = await _playlists.removeSong(playlistId, songId);
    if (result == PlaylistMutationResult.success) {
      final l10n = Get.context?.l10n;
      if (l10n != null) {
        showAppToast(l10n.playlist_song_removed, category: AppToastCategory.playlist);
      }
    } else {
      showPlaylistMutationSnackbar(result);
    }
  }
}
