/// Shared Firebase config (same project as ServiceMusic `music-c223e`).
abstract final class FirebaseConstants {
  static const projectId = 'music-c223e';

  /// Web client ID (OAuth `client_type: 3`) — required for Google Sign-In + Firebase Auth.
  static const webClientId =
      '221870413468-r2n3n8cs0p4i3kgr36lqbmvbrvividus.apps.googleusercontent.com';

  static const usersCollection = 'users';
  static const songsCollection = 'songs';
  static const singersCollection = 'singers';
  static const categoriesCollection = 'categories';
  static const advertisementsCollection = 'advertisements';

  static const favouriteSongsCollection = 'favouriteSongs';
  static const playlistsCollection = 'playlists';
  static const followedSingersCollection = 'followedSingers';
  static const recentSongsCollection = 'recentSongs';
  static const searchQueriesCollection = 'searchQueries';

  static const googleProvider = 'google.com';
}
