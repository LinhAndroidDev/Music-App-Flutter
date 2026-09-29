import 'dart:async';

import 'package:get/get.dart';

import '../../../core/navigation/app_route.dart';
import '../../../data/models/song.dart';
import '../../../data/services/playlist_repository.dart';
import '../playlist_mutation_ui.dart';
import '../playlist_song_catalog.dart';

class AddPlaylistSongsController extends GetxController {
  AddPlaylistSongsController({PlaylistRepository? playlists})
      : _playlists = playlists ?? Get.find<PlaylistRepository>();

  final PlaylistRepository _playlists;

  final playlistId = Get.parameters[AppRouteParam.playlistId] ?? '';

  final query = ''.obs;
  final displaySongs = <Song>[].obs;
  final addedSongIds = <String>{}.obs;
  final isLoading = true.obs;

  Timer? _debounce;
  StreamSubscription<List<Song>>? _songsSub;
  String _coverUrl = '';
  String _playlistTitle = '';
  StreamSubscription? _playlistSub;

  @override
  void onInit() {
    super.onInit();
    _songsSub = _playlists.watchSongs(playlistId).listen(_onPlaylistSongs);
    _playlistSub = _playlists.watchPlaylist(playlistId).listen((p) {
      _coverUrl = p?.coverUrl ?? '';
      _playlistTitle = p?.title ?? '';
    });
    _loadSuggestions();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    _songsSub?.cancel();
    _playlistSub?.cancel();
    super.onClose();
  }

  void _onPlaylistSongs(List<Song> songs) {
    addedSongIds.assignAll(songs.map((s) => s.id));
    if (query.value.trim().isEmpty) {
      _publishSuggestions();
    } else {
      addedSongIds.refresh();
    }
  }

  Future<void> _loadSuggestions() async {
    isLoading.value = true;
    await ensurePlaylistCatalogLoaded();
    _publishSuggestions();
  }

  void _publishSuggestions() {
    final catalog = mergePlaylistCatalog();
    final suggestions = randomPlaylistSuggestions(catalog, addedSongIds.toSet())
        .take(playlistSuggestionLimit)
        .toList();
    displaySongs.assignAll(suggestions);
    isLoading.value = false;
  }

  void onQueryChanged(String raw) {
    _debounce?.cancel();
    query.value = raw;
    if (raw.trim().isEmpty) {
      _publishSuggestions();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      await ensurePlaylistCatalogLoaded();
      final filtered = filterPlaylistCatalog(mergePlaylistCatalog(), raw.trim());
      displaySongs.assignAll(filtered);
      isLoading.value = false;
    });
  }

  Future<void> addSong(Song song) async {
    if (addedSongIds.contains(song.id)) return;
    final result = await _playlists.addSong(playlistId, song, currentCoverUrl: _coverUrl);
    if (result == PlaylistMutationResult.success) {
      _coverUrl = _coverUrl.isEmpty ? song.thumbnailUrl : _coverUrl;
    }
    showPlaylistMutationSnackbar(
      result,
      playlistName: _playlistTitle.isNotEmpty ? _playlistTitle : null,
    );
  }
}
