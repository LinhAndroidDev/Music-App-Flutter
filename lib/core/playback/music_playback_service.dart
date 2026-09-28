import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../data/playback/playback_preferences.dart';
import '../../data/playback/playable_uri_resolver.dart';
import '../../data/playback/song_playback_repository.dart';
import '../../data/services/recent_history_repository.dart';
import 'music_audio_handler.dart';
import 'music_playback_registry.dart';

class MusicPlaybackService {
  MusicPlaybackService._();

  static MusicPlaybackRegistry get _registry => Get.find<MusicPlaybackRegistry>();

  static MusicAudioHandler get handler {
    final h = _registry.handler;
    if (h == null) {
      throw StateError('MusicPlaybackService not initialized');
    }
    return h;
  }

  static bool get isReady => _registry.handler != null;

  /// Safe to call from many places; [AudioService.init] runs at most once per process.
  static Future<void> init() {
    final reg = _registry;
    if (reg.handler != null) {
      return Future.value();
    }
    return reg.initFuture ??= _doInit(reg);
  }

  static bool _isAudioServiceInitialized() {
    try {
      AudioService.cacheManager;
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _doInit(MusicPlaybackRegistry reg) async {
    try {
      if (_isAudioServiceInitialized()) {
        if (reg.handler != null) return;
        throw StateError(
          'Audio service đã chạy nhưng mất handler (thường do hot reload). '
          'Stop app và chạy lại bằng flutter run — không dùng hot reload sau khi sửa playback.',
        );
      }

      await Get.find<PlaybackPreferences>().warmUp();
      reg.handler = await AudioService.init(
        builder: () => MusicAudioHandler(
          queueRepo: Get.find<SongPlaybackRepository>(),
          uriResolver: Get.find<PlayableUriResolver>(),
          preferences: Get.find<PlaybackPreferences>(),
          recentHistory: Get.find<RecentHistoryRepository>(),
        ),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'CHANNEL_MEDIA_PLAYBACK',
          androidNotificationChannelName: 'Phát nhạc',
          androidStopForegroundOnPause: true,
          androidNotificationIcon: 'mipmap/ic_launcher',
          fastForwardInterval: Duration(seconds: 10),
          rewindInterval: Duration(seconds: 10),
        ),
      );
    } on AssertionError catch (e, st) {
      reg.initFuture = null;
      if (_isAudioServiceInitialized()) {
        throw StateError(
          'Audio service đã được khởi tạo. Stop app và chạy lại (flutter run), '
          'không hot reload khi đang phát nhạc.',
        );
      }
      if (kDebugMode) {
        Error.throwWithStackTrace(e, st);
      }
      rethrow;
    } catch (e, st) {
      reg.initFuture = null;
      Error.throwWithStackTrace(e, st);
    }
  }
}
