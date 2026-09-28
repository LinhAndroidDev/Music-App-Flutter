/// Which rows to show in [SongOptionsSheet] — mirrors ServiceMusic
/// `BottomSheetOptionMusic` arguments and callbacks.
class SongOptionsConfig {
  const SongOptionsConfig({
    this.showSleepTimer = false,
    this.showRemoveFromPlaylist = false,
    this.onRemoveFromPlaylist,
    this.onRemoveFavourite,
  });

  /// Default for home, search, category, singer, recent, downloaded, favourite lists.
  static const list = SongOptionsConfig();

  /// [FragmentMusic] — player overflow menu.
  static const player = SongOptionsConfig(showSleepTimer: true);

  /// [PlaylistDetailFragment] — `KEY_SHOW_REMOVE_FROM_PLAYLIST`.
  static SongOptionsConfig playlistDetail({
    required Future<void> Function() onRemoveFromPlaylist,
  }) {
    return SongOptionsConfig(
      showRemoveFromPlaylist: true,
      onRemoveFromPlaylist: onRemoveFromPlaylist,
    );
  }

  /// Optional custom unfavourite flow ([FavouriteSongFragment.removeFavourite]).
  static SongOptionsConfig favouriteList({
    Future<void> Function()? onRemoveFavourite,
  }) {
    return SongOptionsConfig(onRemoveFavourite: onRemoveFavourite);
  }

  final bool showSleepTimer;
  final bool showRemoveFromPlaylist;
  final Future<void> Function()? onRemoveFromPlaylist;
  final Future<void> Function()? onRemoveFavourite;
}
