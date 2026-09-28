import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/models/song.dart';
import '../../data/playback/playback_preferences.dart';
import '../../data/playback/playable_uri_resolver.dart';
import '../../data/playback/song_playback_repository.dart';
import '../../data/services/recent_history_repository.dart';
import 'playback_state.dart' as app;
import 'repeat_mode.dart';
import 'sleep_timer_state.dart';

class MusicAudioHandler extends BaseAudioHandler with SeekHandler, QueueHandler {
  MusicAudioHandler({
    required SongPlaybackRepository queueRepo,
    required PlayableUriResolver uriResolver,
    required PlaybackPreferences preferences,
    required RecentHistoryRepository recentHistory,
  })  : _queueRepo = queueRepo,
        _uriResolver = uriResolver,
        _preferences = preferences,
        _recentHistory = recentHistory {
    _init();
  }

  final SongPlaybackRepository _queueRepo;
  final PlayableUriResolver _uriResolver;
  final PlaybackPreferences _preferences;
  final RecentHistoryRepository _recentHistory;

  final AudioPlayer _player = AudioPlayer();
  final _uiStateController = StreamController<app.PlaybackState>.broadcast();

  app.PlaybackState _uiState = app.PlaybackState.idle;
  app.PlaybackState get uiState => _uiState;
  Stream<app.PlaybackState> get uiStateStream => _uiStateController.stream;

  SleepTimerState _sleepTimer = SleepTimerState.idle;
  SleepTimerState get sleepTimerState => _sleepTimer;

  int _queueIndex = -1;
  int _prepareGeneration = 0;
  String? _historyRecordedForSongId;
  Timer? _sleepTimerTimer;
  void _init() {
    unawaited(_configureAudioSession());
    _player.playerStateStream.listen(_onPlayerState);
    _player.positionStream.listen((pos) {
      _emitUi(
        _uiState.copyWith(
          positionMs: pos.inMilliseconds,
          durationMs: _player.duration?.inMilliseconds ?? _uiState.durationMs,
        ),
      );
      _broadcastPlaybackState();
    });
    _player.durationStream.listen((d) {
      if (d != null) {
        _emitUi(_uiState.copyWith(durationMs: d.inMilliseconds));
      }
    });
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        unawaited(_onTrackCompleted());
      }
    });
  }

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  void _emitUi(app.PlaybackState state) {
    _uiState = state;
    if (!_uiStateController.isClosed) {
      _uiStateController.add(state);
    }
  }

  Future<void> playSong(Song song, {int? queueIndex, int startPositionMs = 0}) async {
    if (song.id.isEmpty) return;
    var index = queueIndex;
    if (index == null || index < 0) {
      index = _queueRepo.indexOf(song);
      if (index < 0) {
        index = _queueRepo.ensureQueueForSongId(song.id);
      }
    }
    if (index < 0) {
      _queueRepo.setPlaybackQueue([song]);
      index = 0;
    }
    _queueIndex = index;
    await _startStreaming(song, startPositionMs, autoStart: true);
  }

  Future<void> playSongAtIndex(int index) async {
    if (!_queueRepo.isLoaded()) return;
    final last = _queueRepo.lastIndex();
    if (last < 0) return;
    final safe = index.clamp(0, last);
    _queueIndex = safe;
    await playSong(_queueRepo.getSong(safe), queueIndex: safe);
  }

  Future<void> playFromVisibleList(List<Song> songs, String songId) async {
    final index = songs.indexWhere((s) => s.id == songId);
    if (index < 0) return;
    _queueRepo.setPlaybackQueue(songs);
    await playSong(songs[index], queueIndex: index);
  }

  Future<void> _startStreaming(
    Song song,
    int startPositionMs, {
    required bool autoStart,
  }) async {
    final uri = await _uriResolver.resolve(song);
    if (uri == null) {
      _emitUi(_uiState.copyWith(isPlaying: false, hasActivePlayer: false));
      return;
    }

    _cancelSleepTimerTimer();
    final generation = ++_prepareGeneration;
    await _applyRepeatMode();

    try {
      await _player.stop();
      if (uri.startsWith('http')) {
        await _player.setUrl(uri);
      } else {
        await _player.setFilePath(uri);
      }
      if (generation != _prepareGeneration) return;
      if (startPositionMs > 0) {
        await _player.seek(Duration(milliseconds: startPositionMs));
      }
      _historyRecordedForSongId = null;
      await _publishMedia(song);
      _emitUi(
        _uiState.copyWith(
          currentSong: song,
          queueIndex: _queueIndex,
          hasActivePlayer: true,
          isShuffleEnabled: _queueRepo.isShuffleEnabled(),
          positionMs: startPositionMs,
        ),
      );
      if (autoStart) {
        await _player.play();
      }
      await _recordRecentOnce(song);
    } catch (_) {
      _emitUi(_uiState.copyWith(isPlaying: false));
    }
  }

  Future<void> _publishMedia(Song song) async {
    final item = _songToMediaItem(song);
    mediaItem.add(item);
    queue.add([item]);
    _broadcastPlaybackState();
  }

  MediaItem _songToMediaItem(Song song) {
    Uri? artUri;
    if (song.thumbnailUrl.isNotEmpty) {
      artUri = Uri.tryParse(song.thumbnailUrl);
    }
    return MediaItem(
      id: song.id,
      title: song.title,
      artist: song.nameSinger,
      duration: song.durationSec > 0
          ? Duration(seconds: song.durationSec)
          : null,
      artUri: artUri,
    );
  }

  Future<void> _applyRepeatMode() async {
    final mode = await _preferences.getRepeatMode();
    if (mode == RepeatMode.repeatOne) {
      await _player.setLoopMode(LoopMode.one);
    } else {
      await _player.setLoopMode(LoopMode.off);
    }
  }

  Future<void> setUserRepeatMode(RepeatMode mode) async {
    await _preferences.saveRepeatMode(mode);
    await _applyRepeatMode();
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    final mapped = switch (repeatMode) {
      AudioServiceRepeatMode.none => RepeatMode.notRepeat,
      AudioServiceRepeatMode.one => RepeatMode.repeatOne,
      AudioServiceRepeatMode.all => RepeatMode.repeatAll,
      AudioServiceRepeatMode.group => RepeatMode.repeatAll,
    };
    await setUserRepeatMode(mapped);
  }

  Future<void> toggleShuffle(String currentSongId) async {
    final enabled = !_queueRepo.isShuffleEnabled();
    final newIndex = _queueRepo.setShuffleEnabled(enabled, currentSongId);
    if (newIndex >= 0) {
      _queueIndex = newIndex;
    }
    _emitUi(
      _uiState.copyWith(isShuffleEnabled: _queueRepo.isShuffleEnabled()),
    );
  }

  void _onPlayerState(PlayerState state) {
    _emitUi(_uiState.copyWith(isPlaying: state.playing));
    _broadcastPlaybackState();
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  void _broadcastPlaybackState() {
    final playing = _player.playing;
    final controls = <MediaControl>[
      MediaControl.skipToPrevious,
      if (playing) MediaControl.pause else MediaControl.play,
      MediaControl.skipToNext,
    ];
    playbackState.add(
      PlaybackState(
        controls: controls,
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: _mapProcessingState(_player.processingState),
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _queueIndex >= 0 ? _queueIndex : 0,
      ),
    );
  }

  Future<void> _onTrackCompleted() async {
    if (_sleepTimer.stopAtEndOfTrack) {
      _sleepTimer = SleepTimerState.idle;
      await _player.seek(Duration.zero);
      await pause();
      return;
    }
    final repeat = await _preferences.getRepeatMode();
    if (repeat == RepeatMode.repeatOne) return;

    if (_queueIndex < _queueRepo.lastIndex()) {
      _queueIndex++;
      await playSong(_queueRepo.getSong(_queueIndex), queueIndex: _queueIndex);
    } else if (repeat == RepeatMode.repeatAll) {
      _queueIndex = 0;
      await playSong(_queueRepo.getSong(0), queueIndex: 0);
    } else {
      await pause();
    }
  }

  @override
  Future<void> play() async {
    if (_player.audioSource == null && _uiState.currentSong != null) {
      await playSong(_uiState.currentSong!, queueIndex: _queueIndex);
      return;
    }
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> playPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _emitUi(
      _uiState.copyWith(
        positionMs: position.inMilliseconds,
        seekSequence: _uiState.seekSequence + 1,
      ),
    );
  }

  Future<void> seekToMs(int positionMs) => seek(Duration(milliseconds: positionMs));

  @override
  Future<void> skipToNext() async {
    if (_queueIndex < 0 && !_queueRepo.isLoaded()) return;
    final repeat = await _preferences.getRepeatMode();
    if (_queueIndex < _queueRepo.lastIndex()) {
      _queueIndex++;
    } else if (repeat == RepeatMode.repeatAll) {
      _queueIndex = 0;
    } else {
      return;
    }
    await playSong(_queueRepo.getSong(_queueIndex), queueIndex: _queueIndex);
  }

  @override
  Future<void> skipToPrevious() async {
    if (_queueIndex < 0 && !_queueRepo.isLoaded()) return;
    if (_queueIndex > 0) {
      _queueIndex--;
    } else {
      _queueIndex = _queueRepo.lastIndex();
    }
    await playSong(_queueRepo.getSong(_queueIndex), queueIndex: _queueIndex);
  }

  Future<void> setSleepTimer(SleepTimerOption option, {int? customDurationMs}) async {
    _cancelSleepTimerTimer();
    if (option == SleepTimerOption.endOfTrack) {
      _sleepTimer = const SleepTimerState(
        active: true,
        stopAtEndOfTrack: true,
        option: SleepTimerOption.endOfTrack,
      );
      return;
    }
    final ms = customDurationMs ?? option.presetDurationMs;
    if (ms == null) return;
    _sleepTimer = SleepTimerState(
      active: true,
      endsAtEpochMs: DateTime.now().millisecondsSinceEpoch + ms,
      option: option,
    );
    _sleepTimerTimer = Timer(Duration(milliseconds: ms), () {
      unawaited(_onSleepTimerExpired());
    });
  }

  void cancelSleepTimer() {
    _cancelSleepTimerTimer();
    _sleepTimer = SleepTimerState.idle;
  }

  void _cancelSleepTimerTimer() {
    _sleepTimerTimer?.cancel();
    _sleepTimerTimer = null;
  }

  Future<void> _onSleepTimerExpired() async {
    _sleepTimer = SleepTimerState.idle;
    await pause();
    await _player.seek(Duration.zero);
  }

  Future<void> _recordRecentOnce(Song song) async {
    if (_historyRecordedForSongId == song.id) return;
    _historyRecordedForSongId = song.id;
    await _recentHistory.recordSong(song);
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }
}
