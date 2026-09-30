/// Shared-element tags aligned with ServiceMusic [PlaylistSharedElement].
abstract final class PlaylistSharedElement {
  static String coverTag(String playlistId) => 'playlist_cover_$playlistId';

  static String titleTag(String playlistId) => 'playlist_title_$playlistId';
}
