import 'dart:math';

import 'package:get/get.dart';

import '../models/song.dart';
import '../services/firestore_music_repository.dart';
import '../services/home_catalog_service.dart';

/// Active playback queue + latest/top caches (ServiceMusic SongRepository).
class SongPlaybackRepository extends GetxService {
  SongPlaybackRepository({
    FirestoreMusicRepository? musicRepository,
    HomeCatalogService? catalog,
  })  : _music = musicRepository ?? Get.find<FirestoreMusicRepository>(),
        _catalog = catalog ?? Get.find<HomeCatalogService>();

  final FirestoreMusicRepository _music;
  final HomeCatalogService _catalog;

  final List<Song> _latestCache = [];
  final List<Song> _topCache = [];
  final List<Song> _playbackQueue = [];
  final List<Song> _sequentialQueue = [];
  bool _shuffleEnabled = false;

  List<Song> getPlaylist() => List.unmodifiable(_playbackQueue);

  List<Song> getLatestPlaylist() => List.unmodifiable(_latestCache);

  List<Song> getTopPlaylist() => List.unmodifiable(_topCache);

  bool isShuffleEnabled() => _shuffleEnabled;

  bool isLoaded() => _playbackQueue.isNotEmpty;

  int lastIndex() => _playbackQueue.isEmpty ? -1 : _playbackQueue.length - 1;

  int size() => _playbackQueue.length;

  Song getSong(int index) {
    if (_playbackQueue.isEmpty) {
      throw StateError('Playlist not loaded');
    }
    return _playbackQueue[index.clamp(0, _playbackQueue.length - 1)];
  }

  Song? getSongById(String id) {
    for (final s in _playbackQueue) {
      if (s.id == id) return s;
    }
    for (final s in _latestCache) {
      if (s.id == id) return s;
    }
    for (final s in _topCache) {
      if (s.id == id) return s;
    }
    return null;
  }

  int indexOf(Song song) =>
      _playbackQueue.indexWhere((s) => s.id == song.id);

  void setPlaybackQueue(List<Song> songs) {
    _clearShuffleState();
    _playbackQueue
      ..clear()
      ..addAll(songs);
  }

  int ensureQueueForSongId(String songId) {
    if (songId.isEmpty) return -1;
    final inQueue = _playbackQueue.indexWhere((s) => s.id == songId);
    if (inQueue >= 0) return inQueue;

    final inLatest = _latestCache.indexWhere((s) => s.id == songId);
    if (inLatest >= 0) {
      _clearShuffleState();
      _playbackQueue
        ..clear()
        ..addAll(_latestCache);
      return inLatest;
    }

    final inTop = _topCache.indexWhere((s) => s.id == songId);
    if (inTop >= 0) {
      _clearShuffleState();
      _playbackQueue
        ..clear()
        ..addAll(_topCache);
      return inTop;
    }
    return -1;
  }

  int setShuffleEnabled(bool enabled, String currentSongId) {
    if (_playbackQueue.isEmpty) {
      _shuffleEnabled = false;
      _sequentialQueue.clear();
      return -1;
    }
    if (enabled) {
      if (!_shuffleEnabled) {
        _sequentialQueue
          ..clear()
          ..addAll(_playbackQueue);
      }
      final source =
          _sequentialQueue.isNotEmpty ? List<Song>.from(_sequentialQueue) : List<Song>.from(_playbackQueue);
      _playbackQueue
        ..clear()
        ..addAll(source..shuffle(Random()));
      _shuffleEnabled = true;
    } else {
      if (_sequentialQueue.isNotEmpty) {
        _playbackQueue
          ..clear()
          ..addAll(_sequentialQueue);
      }
      _clearShuffleState();
    }
    return _playbackQueue.indexWhere((s) => s.id == currentSongId);
  }

  Future<void> refreshPlaylist({bool fromServer = true}) async {
    if (fromServer) {
      await _catalog.refreshAll();
    } else {
      await _catalog.ensureLatest();
      await _catalog.ensureTop();
    }
    _syncCachesFromCatalog();
  }

  void syncCachesFromCatalog() => _syncCachesFromCatalog();

  void _syncCachesFromCatalog() {
    _latestCache
      ..clear()
      ..addAll(_catalog.latestSongs);
    _topCache
      ..clear()
      ..addAll(_catalog.topSongs);
  }

  Future<void> refreshTopPlaylist({bool fromServer = true}) async {
    if (fromServer) {
      await _music.getTopSongs(limit: 100, fromServer: true);
      await _catalog.ensureTop();
    }
    _topCache
      ..clear()
      ..addAll(_catalog.topSongs);
  }

  void _clearShuffleState() {
    _shuffleEnabled = false;
    _sequentialQueue.clear();
  }
}
