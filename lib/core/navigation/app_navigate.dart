import 'package:get/get.dart';

import '../../modules/main/main_controller.dart';
import 'app_route.dart';

/// Central navigation API (wraps GetX routing).
abstract final class AppNavigate {
  AppNavigate._();

  static void back<T>({T? result}) {
    Get.back<T>(result: result);
  }

  static void backUntilMain() {
    Get.until((route) => route.settings.name == AppRoute.main);
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

  /// Switches tab when [AppRoute.main] is already visible.
  static void switchMainTab(int tab) {
    if (Get.currentRoute != AppRoute.main) {
      toMain(tab: tab);
      return;
    }
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().selectTab(tab);
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
