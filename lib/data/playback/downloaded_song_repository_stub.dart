import 'downloaded_song_repository.dart';

class DownloadedSongRepositoryStub implements DownloadedSongRepository {
  @override
  Future<String?> resolveLocalPlayableUri(String songId) async => null;
}
