/// Local downloaded audio path (ServiceMusic DownloadedSongRepository).
abstract class DownloadedSongRepository {
  Future<String?> resolveLocalPlayableUri(String songId);
}
