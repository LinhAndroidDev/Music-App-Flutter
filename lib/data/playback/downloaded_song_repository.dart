import 'package:get/get.dart';

import '../download/download_status.dart';
import '../models/song.dart';
import 'download_enqueue_result.dart';

/// Local downloaded audio (ServiceMusic [DownloadedSongRepository]).
abstract class DownloadedSongRepository extends GetxService {
  RxList<Song> get completedSongs;
  RxInt get completedCount;

  Future<String?> resolveLocalPlayableUri(String songId);

  Future<String?> resolveLocalLyricPath(String songId);

  Future<DownloadEnqueueResult> enqueueDownload(Song song);

  Future<void> cancelDownload(String songId);

  Future<void> deleteDownload(String songId);

  Stream<DownloadStatus?> watchStatus(String songId);

  Future<DownloadStatus?> getStatus(String songId);
}
