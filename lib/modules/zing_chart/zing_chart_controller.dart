import 'dart:math';

import 'package:get/get.dart';

import '../../core/base/base_controller.dart';
import '../../data/models/song.dart';
import '../../data/playback/song_playback_repository.dart';
import '../../data/services/home_catalog_service.dart';
import '../library/utils/library_playback.dart';
import 'utils/chart_date_format.dart';

class ZingChartController extends BaseController {
  ZingChartController({
    HomeCatalogService? catalog,
    SongPlaybackRepository? songQueue,
  })  : _catalog = catalog ?? Get.find<HomeCatalogService>(),
        _songQueue = songQueue ?? Get.find<SongPlaybackRepository>();

  final HomeCatalogService _catalog;
  final SongPlaybackRepository _songQueue;
  final _random = Random();

  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final playlist = <Song>[].obs;
  final chartDateLabel = ChartDateFormat.timeWithHourCurrent().obs;
  final showSuggested = true.obs;

  String? _suggestedSongId;

  @override
  void onInit() {
    super.onInit();
    ensureLoaded();
  }

  Future<void> ensureLoaded() async {
    if (playlist.isNotEmpty) {
      isLoading.value = false;
      return;
    }
    final cached = _catalog.topSongs;
    if (cached.isNotEmpty) {
      _applyPlaylist(cached);
      isLoading.value = false;
      return;
    }
    await loadTopSongs(force: true);
  }

  Future<void> loadTopSongs({bool force = false}) async {
    if (!force && playlist.isNotEmpty) return;
    if (!force) {
      final cached = _catalog.topSongs;
      if (cached.isNotEmpty) {
        _applyPlaylist(cached);
        isLoading.value = false;
        return;
      }
    }
    isLoading.value = true;
    try {
      if (force) {
        await _catalog.refreshTop();
      } else {
        await _catalog.ensureTop();
      }
      _applyPlaylist(_catalog.topSongs);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshTopSongs() async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;
    try {
      await _catalog.refreshTop();
      _applyPlaylist(_catalog.topSongs);
      chartDateLabel.value = ChartDateFormat.timeWithHourCurrent();
    } finally {
      isRefreshing.value = false;
    }
  }

  void _applyPlaylist(List<Song> songs) {
    playlist.assignAll(songs);
    if (songs.isNotEmpty) {
      _songQueue.syncCachesFromCatalog();
      _ensureSuggestedSong();
    } else {
      _suggestedSongId = null;
    }
  }

  void _ensureSuggestedSong() {
    if (playlist.isEmpty) {
      _suggestedSongId = null;
      return;
    }
    final id = _suggestedSongId;
    if (id != null && playlist.any((s) => s.id == id)) return;
    _suggestedSongId = playlist[_random.nextInt(playlist.length)].id;
  }

  Song? get suggestedSong {
    if (!showSuggested.value || playlist.isEmpty) return null;
    final id = _suggestedSongId;
    if (id == null) return null;
    for (final s in playlist) {
      if (s.id == id) return s;
    }
    return null;
  }

  void dismissSuggested() {
    showSuggested.value = false;
  }

  Future<void> playSong(String songId) async {
    if (songId.isEmpty) return;
    await playVisibleSongList(playlist.toList(), songId);
  }
}
