import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../core/playback/playback_controller.dart';
import '../../data/playback/song_playback_repository.dart';
import '../../modules/main/main_controller.dart';
import '../../modules/player/music_player_coordinator.dart';
import '../../modules/player/player_binding.dart';
import 'app_route.dart';

/// Central navigation API (wraps GetX routing).
abstract final class AppNavigate {
  AppNavigate._();

  /// Pops after the current frame — avoids `Navigator._debugLocked` during gestures/transitions.
  static void back<T>({T? result}) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final navigator = Get.key.currentState;
      if (navigator != null && navigator.canPop()) {
        navigator.pop<T>(result);
        return;
      }
      if (Get.isOverlaysOpen || Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
        Get.back<T>(result: result);
      }
    });
  }

  static void backUntilMain() {
    _returnToMainStack(preserveCurrentTab: true);
  }

  static void offAllNamed(
    String route, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) {
    Get.offAllNamed(route, arguments: arguments, parameters: parameters);
  }

  // --- Splash & shell ---

  static void toSplash() {
    Get.offAllNamed(AppRoute.splash);
  }

  /// Opens main shell; optional [tab] selects bottom bar item ([AppTab]).
  static void toMain({int tab = AppTab.discover}) {
    Get.offAllNamed(
      AppRoute.main,
      parameters: {AppRouteParam.tab: '$tab'},
    );
  }

  static void toLibraryTab() => toMain(tab: AppTab.library);

  static void toDiscoverTab() => toMain(tab: AppTab.discover);

  static void toZingChartTab() => toMain(tab: AppTab.zingChart);

  static void toRadioTab() => toMain(tab: AppTab.radio);

  static void toProfileTab() => toMain(tab: AppTab.profile);

  /// Updates the main tab and returns to [AppRoute.main] when a stack screen is open.
  static void switchMainTab(int tab) {
    if (!Get.isRegistered<MainController>()) return;
    Get.find<MainController>().selectTab(tab);
    if (_isMainTopRoute) return;
    _returnToMainStack(tab: tab);
  }

  /// Clears stack screens back to main — avoids [HeroController] failures from [Get.until]/popUntil.
  static void _returnToMainStack({int? tab, bool preserveCurrentTab = false}) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!Get.isRegistered<MainController>()) return;
      final main = Get.find<MainController>();
      final tabIndex =
          preserveCurrentTab ? main.currentTab.value : (tab ?? main.currentTab.value);
      Get.offAllNamed(
        AppRoute.main,
        parameters: {AppRouteParam.tab: '$tabIndex'},
      );
    });
  }

  /// Top GetX route is main (not a stack screen pushed on top).
  static bool get _isMainTopRoute {
    final route = Get.currentRoute;
    if (_routeIsMain(route)) return true;
    return _routeIsMain(Get.routing.current);
  }

  static bool _routeIsMain(String route) {
    return route == AppRoute.main || route.startsWith('${AppRoute.main}?');
  }

  // --- Player ---

  static Future<void>? _openPlayerFuture;

  /// Shows full-screen player UI immediately (sync).
  static void presentPlayerUi() {
    PlayerBinding().dependencies();
    Get.find<MusicPlayerCoordinator>().show();
  }

  static void closePlayer() {
    if (Get.isRegistered<MusicPlayerCoordinator>()) {
      Get.find<MusicPlayerCoordinator>().hide();
    }
  }

  static Future<void> openPlayer({
    String? songId,
    bool preservePlayback = false,
  }) {
    // Avoid nested navigation / Obx rebuild while Navigator is locked (e.g. mini player tap mid-transition).
    if (_openPlayerFuture != null) {
      return _openPlayerFuture!;
    }
    final completer = _openPlayerFuture = _openPlayerImpl(
      songId: songId,
      preservePlayback: preservePlayback,
    ).whenComplete(() => _openPlayerFuture = null);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      presentPlayerUi();
    });
    return completer;
  }

  static Future<void> _openPlayerImpl({
    String? songId,
    bool preservePlayback = false,
  }) async {
    final playback = Get.find<PlaybackController>();
    await playback.ensureReady();

    if (!preservePlayback && songId != null && songId.isNotEmpty) {
      final queue = Get.find<SongPlaybackRepository>();
      final index = queue.ensureQueueForSongId(songId);
      if (index >= 0) {
        await playback.playSongAtIndex(index);
      } else {
        final song = queue.getSongById(songId);
        if (song != null) {
          await playback.playSong(song);
        }
      }
    }
  }

  // --- Stack screens (NavHost destinations) ---

  static Future<T?>? toCategorySongs<T>({
    required String title,
    required String mode,
    String categoryId = '',
  }) {
    return Get.toNamed<T>(
      AppRoute.categorySongs,
      parameters: {
        AppRouteParam.title: title,
        AppRouteParam.mode: mode,
        AppRouteParam.categoryId: categoryId,
      },
    );
  }

  static Future<T?>? toFavouriteSong<T>() => Get.toNamed<T>(AppRoute.favouriteSong);

  static Future<T?>? toDownloadedSongs<T>() => Get.toNamed<T>(AppRoute.downloadedSongs);

  static Future<T?>? toSearchSong<T>({String committedQuery = ''}) {
    return Get.toNamed<T>(
      AppRoute.searchSong,
      parameters: {AppRouteParam.committedQuery: committedQuery},
    );
  }

  static Future<T?>? toSingerDetail<T>({required String singerId}) {
    return Get.toNamed<T>(
      AppRoute.singerDetail,
      parameters: {AppRouteParam.singerId: singerId},
    );
  }

  static Future<T?>? toPlaylistDetail<T>({
    required String playlistId,
    String playlistTitle = '',
    String playlistCoverUrl = '',
  }) {
    return Get.toNamed<T>(
      AppRoute.playlistDetail,
      parameters: {
        AppRouteParam.playlistId: playlistId,
        AppRouteParam.playlistTitle: playlistTitle,
        AppRouteParam.playlistCoverUrl: playlistCoverUrl,
      },
    );
  }

  static Future<T?>? toAddPlaylistSongs<T>({required String playlistId}) {
    return Get.toNamed<T>(
      AppRoute.addPlaylistSongs,
      parameters: {AppRouteParam.playlistId: playlistId},
    );
  }

  static Future<T?>? toEditPlaylist<T>({required String playlistId}) {
    return Get.toNamed<T>(
      AppRoute.editPlaylist,
      parameters: {AppRouteParam.playlistId: playlistId},
    );
  }

  static Future<T?>? toRecentHistory<T>() => Get.toNamed<T>(AppRoute.recentHistory);

  static Future<T?>? toFollowedSingers<T>() => Get.toNamed<T>(AppRoute.followedSingers);

  static Future<T?>? toAddArtist<T>() => Get.toNamed<T>(AppRoute.addArtist);
}
