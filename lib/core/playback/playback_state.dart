import '../../data/models/song.dart';

class PlaybackState {
  const PlaybackState({
    this.currentSong,
    this.queueIndex = -1,
    this.isPlaying = false,
    this.positionMs = 0,
    this.durationMs = 0,
    this.hasActivePlayer = false,
    this.isShuffleEnabled = false,
    this.seekSequence = 0,
  });

  final Song? currentSong;
  final int queueIndex;
  final bool isPlaying;
  final int positionMs;
  final int durationMs;
  final bool hasActivePlayer;
  final bool isShuffleEnabled;
  final int seekSequence;

  static const idle = PlaybackState();

  PlaybackState copyWith({
    Song? currentSong,
    int? queueIndex,
    bool? isPlaying,
    int? positionMs,
    int? durationMs,
    bool? hasActivePlayer,
    bool? isShuffleEnabled,
    int? seekSequence,
    bool clearSong = false,
  }) {
    return PlaybackState(
      currentSong: clearSong ? null : (currentSong ?? this.currentSong),
      queueIndex: queueIndex ?? this.queueIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      hasActivePlayer: hasActivePlayer ?? this.hasActivePlayer,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      seekSequence: seekSequence ?? this.seekSequence,
    );
  }
}
