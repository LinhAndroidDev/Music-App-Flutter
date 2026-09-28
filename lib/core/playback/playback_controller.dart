import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart' hide PlaybackState;
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/navigation/app_navigate.dart';
import '../../data/models/song.dart';
import '../../data/playback/playback_preferences.dart';
import '../../data/playback/song_playback_repository.dart';
import 'music_audio_handler.dart';
import 'music_playback_service.dart';
import 'playback_state.dart';
import 'repeat_mode.dart';
import 'sleep_timer_state.dart';

class PlaybackController extends GetxController {
  PlaybackController({
    SongPlaybackRepository? queueRepo,
    PlaybackPreferences? preferences,
  })  : _queueRepo = queueRepo ?? Get.find<SongPlaybackRepository>(),
        _preferences = preferences ?? Get.find<PlaybackPreferences>();

  final SongPlaybackRepository _queueRepo;
  final PlaybackPreferences _preferences;

  final playbackState = PlaybackState.idle.obs;
  final sleepTimerState = SleepTimerState.idle.obs;

  StreamSubscription<PlaybackState>? _stateSub;
  StreamSubscription<void>? _notificationTapSub;
  MusicAudioHandler? _handler;

  MusicAudioHandler get handler {
    _handler ??= MusicPlaybackService.handler;
    return _handler!;
  }

  @override
  void onInit() {
    super.onInit();
    _bindHandlerStreams();
  }

  @override
  void onReady() {
    super.onReady();
    Future.microtask(() async {
      await MusicPlaybackService.init();
      _bindHandlerStreams();
      _bindNotificationTap();
    });
  }

  void _bindNotificationTap() {
    _notificationTapSub?.cancel();
    _notificationTapSub = AudioService.notificationClicked.listen((clicked) {
      if (!clicked) return;
      unawaited(_openPlayerFromNotification());
    });
  }

  Future<void> _openPlayerFromNotification() async {
    await AppNavigate.openPlayer(preservePlayback: true);
  }

  Future<void> dismissMiniPlayer() async {
    await ensureReady();
    await handler.dismissPlayback();
    playbackState.value = PlaybackState.idle;
  }

  void _bindHandlerStreams() {
    if (!MusicPlaybackService.isReady) return;
    final h = handler;
    playbackState.value = h.uiState;
    sleepTimerState.value = h.sleepTimerState;
    _stateSub?.cancel();
    _stateSub = h.uiStateStream.listen((s) {
      playbackState.value = s;
      playbackState.refresh();
    });
  }

  Future<void> ensureReady() async {
    await MusicPlaybackService.init();
    _bindHandlerStreams();
  }

  Future<void> ensureNotificationPermission() async {
    if (!Platform.isAndroid) return;
    final status = await Permission.notification.status;
    if (status.isGranted) return;
    await Permission.notification.request();
  }

  List<Song> getPlaylist() => _queueRepo.getPlaylist();

  Future<void> refreshPlaylist() => _queueRepo.refreshPlaylist();

  Future<void> syncCachesFromCatalog() async {
    _queueRepo.syncCachesFromCatalog();
  }

  Future<bool> playFromVisibleList(List<Song> songs, String songId) async {
    if (songId.isEmpty || songs.isEmpty) return false;
    await ensureReady();
    await ensureNotificationPermission();
    await handler.playFromVisibleList(songs, songId);
    return true;
  }

  Future<void> playSong(Song song) async {
    await ensureReady();
    await ensureNotificationPermission();
    await handler.playSong(song);
  }

  Future<void> playSongAtIndex(int index) async {
    await ensureReady();
    await ensureNotificationPermission();
    await handler.playSongAtIndex(index);
  }

  Future<void> playPause() async {
    await ensureReady();
    await handler.playPause();
  }

  Future<void> seekToMs(int ms) async {
    await ensureReady();
    await handler.seekToMs(ms);
  }

  Future<void> skipNext() async {
    await ensureReady();
    await handler.skipToNext();
  }

  Future<void> skipPrevious() async {
    await ensureReady();
    await handler.skipToPrevious();
  }

  Future<RepeatMode> getRepeatMode() => _preferences.getRepeatMode();

  Future<void> setRepeatMode(RepeatMode mode) async {
    await ensureReady();
    await handler.setUserRepeatMode(mode);
  }

  Future<void> cycleRepeatMode() async {
    final current = await getRepeatMode();
    final next = switch (current) {
      RepeatMode.notRepeat => RepeatMode.repeatAll,
      RepeatMode.repeatAll => RepeatMode.repeatOne,
      RepeatMode.repeatOne => RepeatMode.notRepeat,
    };
    await setRepeatMode(next);
  }

  Future<void> toggleShuffle() async {
    await ensureReady();
    final id = playbackState.value.currentSong?.id ?? '';
    await handler.toggleShuffle(id);
  }

  Future<void> setSleepTimer(SleepTimerOption option, {int? customDurationMs}) async {
    await ensureReady();
    await handler.setSleepTimer(option, customDurationMs: customDurationMs);
    sleepTimerState.value = handler.sleepTimerState;
  }

  void cancelSleepTimer() {
    if (!MusicPlaybackService.isReady) return;
    handler.cancelSleepTimer();
    sleepTimerState.value = SleepTimerState.idle;
  }

  @override
  void onClose() {
    _stateSub?.cancel();
    _notificationTapSub?.cancel();
    super.onClose();
  }
}
