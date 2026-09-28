import 'package:get/get.dart';

import '../models/song.dart';
import 'downloaded_song_repository.dart';

class PlayableUriResolver extends GetxService {
  PlayableUriResolver({DownloadedSongRepository? downloads})
      : _downloads = downloads ?? Get.find<DownloadedSongRepository>();

  final DownloadedSongRepository _downloads;

  Future<String?> resolve(Song song) async {
    if (song.id.isNotEmpty) {
      final local = await _downloads.resolveLocalPlayableUri(song.id);
      if (local != null && local.isNotEmpty) return local;
    }
    final remote = song.audioUrl.trim();
    return remote.isNotEmpty ? remote : null;
  }
}
