import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/l10n/l10n.dart';
import '../core/navigation/app_route.dart';
import '../modules/common/stack_page.dart';
import '../modules/main/main_binding.dart';
import '../modules/main/main_page.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_page.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoute.splash;

  static final pages = <GetPage>[
    GetPage(
      name: AppRoute.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoute.main,
      page: () => const MainPage(),
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoute.categorySongs,
      page: () => Builder(builder: categorySongsPage),
    ),
    GetPage(
      name: AppRoute.favouriteSong,
      page: () => Builder(
        builder: (context) => StackPage(title: context.l10n.favourite_songs_title),
      ),
    ),
    GetPage(
      name: AppRoute.downloadedSongs,
      page: () => Builder(
        builder: (context) => StackPage(title: context.l10n.downloaded_songs_title),
      ),
    ),
    GetPage(
      name: AppRoute.searchSong,
      page: () => Builder(builder: searchSongPage),
    ),
    GetPage(
      name: AppRoute.singerDetail,
      page: () => Builder(builder: singerDetailPage),
    ),
    GetPage(
      name: AppRoute.playlistDetail,
      page: () => Builder(builder: playlistDetailPage),
    ),
    GetPage(
      name: AppRoute.addPlaylistSongs,
      page: () => Builder(
        builder: (context) =>
            playlistIdPage(context, context.l10n.playlist_add_songs_title),
      ),
    ),
    GetPage(
      name: AppRoute.editPlaylist,
      page: () => Builder(
        builder: (context) => playlistIdPage(context, context.l10n.playlist_edit_title),
      ),
    ),
    GetPage(
      name: AppRoute.recentHistory,
      page: () => Builder(
        builder: (context) => StackPage(title: context.l10n.recent_history_title),
      ),
    ),
    GetPage(
      name: AppRoute.followedSingers,
      page: () => Builder(
        builder: (context) => StackPage(title: context.l10n.artist_screen_title),
      ),
    ),
    GetPage(
      name: AppRoute.addArtist,
      page: () => Builder(
        builder: (context) => StackPage(title: context.l10n.artist_add),
      ),
    ),
  ];
}
