import 'package:get/get.dart';

import '../download/download_status.dart';
import '../models/song.dart';
import 'download_enqueue_result.dart';
import 'downloaded_song_repository.dart';

/// Placeholder for tests / offline scenarios without DB.
class DownloadedSongRepositoryStub extends DownloadedSongRepository {
  @override
  final completedSongs = <Song>[].obs;

  @override
  final completedCount = 0.obs;

  @override
  Future<String?> resolveLocalPlayableUri(String songId) async => null;

  @override
  Future<String?> resolveLocalLyricPath(String songId) async => null;

  @override
  Future<DownloadEnqueueResult> enqueueDownload(Song song) async =>
      DownloadEnqueueResult.invalidSong;

  @override
  Future<void> cancelDownload(String songId) async {}

  @override
  Future<void> deleteDownload(String songId) async {}

  @override
  Stream<DownloadStatus?> watchStatus(String songId) =>
      Stream<DownloadStatus?>.value(null);

  @override
  Future<DownloadStatus?> getStatus(String songId) async => null;
}
