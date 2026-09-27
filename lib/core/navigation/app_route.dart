/// Route names aligned with ServiceMusic `main_nav.xml`.
///
/// Bottom tabs (Khám phá, Thư viện, …) live under [main] — use [AppTab] + [AppNavigate.toMain].
abstract final class AppRoute {
  static const splash = '/splash';
  static const main = '/main';

  static const categorySongs = '/category-songs';
  static const favouriteSong = '/favourite-song';
  static const downloadedSongs = '/downloaded-songs';
  static const searchSong = '/search-song';
  static const singerDetail = '/singer-detail';
  static const playlistDetail = '/playlist-detail';
  static const addPlaylistSongs = '/add-playlist-songs';
  static const editPlaylist = '/edit-playlist';
  static const recentHistory = '/recent-history';
  static const followedSingers = '/followed-singers';
  static const addArtist = '/add-artist';
}

/// Tab indices for [AppRoute.main] (matches [CustomBottomBar] order in ServiceMusic).
abstract final class AppTab {
  static const library = 0;
  static const discover = 1;
  static const zingChart = 2;
  static const radio = 3;
  static const profile = 4;
}

/// Query / path parameter keys for GetX [Get.parameters].
abstract final class AppRouteParam {
  static const tab = 'tab';

  static const title = 'title';
  static const mode = 'mode';
  static const categoryId = 'categoryId';

  static const committedQuery = 'committedQuery';
  static const singerId = 'singerId';

  static const playlistId = 'playlistId';
  static const playlistTitle = 'playlistTitle';
  static const playlistCoverUrl = 'playlistCoverUrl';
}
