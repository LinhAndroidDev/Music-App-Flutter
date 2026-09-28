import 'dart:async';

import 'package:get/get.dart';

import '../../core/playback/playback_controller.dart';
import '../../core/playback/playback_state.dart' as app_playback;
import '../../core/playback/repeat_mode.dart';
import '../../data/lyrics/song_lyrics_loader.dart';
import '../../data/lyrics/timed_lyric_line.dart';
import '../../data/models/firestore_song.dart' show FirestoreSinger;
import '../../data/models/song.dart';
import '../../data/services/favourite_song_repository.dart';
import '../../data/services/firestore_music_repository.dart';

class PlayerSingerUiState {
  const PlayerSingerUiState({
    this.isLoading = false,
    this.songId = '',
    this.singers = const [],
    this.selectedIndex = 0,
  });

  final bool isLoading;
  final String songId;
  final List<FirestoreSinger> singers;
  final int selectedIndex;
}

class PlayerController extends GetxController {
  PlayerController({
    PlaybackController? playback,
    FavouriteSongRepository? favourites,
    FirestoreMusicRepository? music,
    SongLyricsLoader? lyricsLoader,
  })  : _playback = playback ?? Get.find<PlaybackController>(),
        _favourites = favourites ?? Get.find<FavouriteSongRepository>(),
        _music = music ?? Get.find<FirestoreMusicRepository>(),
        _lyricsLoader = lyricsLoader ?? Get.find<SongLyricsLoader>();

  final PlaybackController _playback;
  final FavouriteSongRepository _favourites;
  final FirestoreMusicRepository _music;
  final SongLyricsLoader _lyricsLoader;

  final isFavourite = false.obs;
  final repeatMode = RepeatMode.notRepeat.obs;
  final singerState = const PlayerSingerUiState().obs;
  final lyricLines = Rxn<List<TimedLyricLine>>();
  final lyricsLoading = false.obs;

  StreamSubscription<bool>? _favSub;
  String? _boundSongId;

  PlaybackController get playback => _playback;

  @override
  void onInit() {
    super.onInit();
    ever(_playback.playbackState, (app_playback.PlaybackState state) {
      final song = state.currentSong;
      if (song != null && song.id != _boundSongId) {
        _onSongChanged(song);
      }
    });
    final current = _playback.playbackState.value.currentSong;
    if (current != null) {
      _onSongChanged(current);
    }
    _refreshRepeatMode();
  }

  @override
  void onClose() {
    _favSub?.cancel();
    super.onClose();
  }

  Future<void> _refreshRepeatMode() async {
    repeatMode.value = await _playback.getRepeatMode();
  }

  void _onSongChanged(Song song) {
    _boundSongId = song.id;
    _favSub?.cancel();
    _favSub = _favourites.watchIsFavourite(song.id).listen((v) {
      isFavourite.value = v;
    });
    loadSingersForSong(song);
    loadLyrics(song);
    _refreshRepeatMode();
  }

  Future<void> loadSingersForSong(Song song) async {
    if (song.id.isEmpty) return;
    singerState.value = PlayerSingerUiState(isLoading: true, songId: song.id);
    try {
      final fs = await _music.getSong(song.id);
      final ids = fs?.displaySingerIds ?? const [];
      final singers = <FirestoreSinger>[];
      if (ids.isNotEmpty) {
        for (final id in ids) {
          final s = await _music.getSinger(id);
          if (s != null) singers.add(s);
        }
      }
      if (singers.isEmpty) {
        final name = fs?.artistText.isNotEmpty == true
            ? fs!.artistText
            : song.nameSinger;
        if (name.isNotEmpty) {
          singers.add(
            FirestoreSinger(id: '', name: name, avatarUrl: '', description: ''),
          );
        }
      }
      if (singerState.value.songId != song.id) return;
      singerState.value = PlayerSingerUiState(
        songId: song.id,
        singers: singers,
        selectedIndex: 0,
      );
    } catch (_) {
      if (singerState.value.songId == song.id) {
        singerState.value = PlayerSingerUiState(songId: song.id);
      }
    }
  }

  void selectSingerTab(int index) {
    final s = singerState.value;
    if (index < 0 || index >= s.singers.length) return;
    singerState.value = PlayerSingerUiState(
      songId: s.songId,
      singers: s.singers,
      selectedIndex: index,
    );
  }

  Future<void> loadLyrics(Song song) async {
    lyricsLoading.value = true;
    lyricLines.value = null;
    final lines = await _lyricsLoader.loadTimedLines(song);
    if (_boundSongId != song.id) return;
    lyricLines.value = lines;
    lyricsLoading.value = false;
  }

  Future<void> toggleFavourite() async {
    final song = _playback.playbackState.value.currentSong;
    if (song == null) return;
    isFavourite.value = await _favourites.toggleFavourite(song);
  }

  Future<void> cycleRepeat() async {
    await _playback.cycleRepeatMode();
    repeatMode.value = await _playback.getRepeatMode();
  }

  Future<void> toggleShuffle() async {
    await _playback.toggleShuffle();
  }
}
