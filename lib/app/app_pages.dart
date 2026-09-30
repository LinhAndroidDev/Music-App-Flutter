import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/l10n/l10n.dart';
import '../core/navigation/app_route.dart';
import '../modules/artist/add_artist_binding.dart';
import '../modules/artist/add_artist_page.dart';
import '../modules/artist/followed_singers_binding.dart';
import '../modules/artist/followed_singers_page.dart';
import '../modules/artist/singer_detail/singer_detail_binding.dart';
import '../modules/artist/singer_detail/singer_detail_page.dart';
import '../modules/category/category_songs_binding.dart';
import '../modules/category/category_songs_page.dart';
import '../modules/common/stack_page.dart';
import '../modules/search/search_binding.dart';
import '../modules/search/search_page.dart';
import '../modules/downloaded/downloaded_songs_binding.dart';
import '../modules/downloaded/downloaded_songs_page.dart';
import '../modules/favourite/favourite_song_binding.dart';
import '../modules/favourite/favourite_song_page.dart';
import '../modules/main/main_binding.dart';
import '../modules/main/main_page.dart';
import '../modules/playlist/add_songs/add_playlist_songs_binding.dart';
import '../modules/playlist/add_songs/add_playlist_songs_page.dart';
import '../modules/playlist/detail/playlist_detail_binding.dart';
import '../modules/playlist/detail/playlist_detail_page.dart';
import '../modules/playlist/edit/edit_playlist_binding.dart';
import '../modules/playlist/edit/edit_playlist_page.dart';
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
      page: () => const CategorySongsPage(),
      binding: CategorySongsBinding(),
    ),
    GetPage(
      name: AppRoute.favouriteSong,
      page: () => const FavouriteSongPage(),
      binding: FavouriteSongBinding(),
    ),
    GetPage(
      name: AppRoute.downloadedSongs,
      page: () => const DownloadedSongsPage(),
      binding: DownloadedSongsBinding(),
    ),
    GetPage(
      name: AppRoute.searchSong,
      page: () => const SearchPage(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: AppRoute.singerDetail,
      page: () => const SingerDetailPage(),
      binding: SingerDetailBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 320),
    ),
    GetPage(
      name: AppRoute.playlistDetail,
      page: () => const PlaylistDetailPage(),
      binding: PlaylistDetailBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 320),
    ),
    GetPage(
      name: AppRoute.addPlaylistSongs,
      page: () => const AddPlaylistSongsPage(),
      binding: AddPlaylistSongsBinding(),
    ),
    GetPage(
      name: AppRoute.editPlaylist,
      page: () => const EditPlaylistPage(),
      binding: EditPlaylistBinding(),
    ),
    GetPage(
      name: AppRoute.recentHistory,
      page: () => Builder(
        builder: (context) => StackPage(title: context.l10n.recent_history_title),
      ),
    ),
    GetPage(
      name: AppRoute.followedSingers,
      page: () => const FollowedSingersPage(),
      binding: FollowedSingersBinding(),
    ),
    GetPage(
      name: AppRoute.addArtist,
      page: () => const AddArtistPage(),
      binding: AddArtistBinding(),
    ),
  ];
}
