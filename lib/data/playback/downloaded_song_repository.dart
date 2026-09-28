import 'package:get/get.dart';

import '../models/song.dart';

/// Local downloaded audio (ServiceMusic [DownloadedSongRepository]).
abstract class DownloadedSongRepository extends GetxService {
  RxList<Song> get completedSongs;
  RxInt get completedCount;

  Future<String?> resolveLocalPlayableUri(String songId);
}
