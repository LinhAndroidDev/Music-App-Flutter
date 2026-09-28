import 'package:get/get.dart';

import '../../core/base/base_controller.dart';
import '../../data/models/song.dart';
import '../../data/playback/downloaded_song_repository.dart';
import '../library/utils/library_playback.dart';

class DownloadedSongsController extends BaseController {
  DownloadedSongsController({DownloadedSongRepository? downloads})
      : _downloads = downloads ?? Get.find<DownloadedSongRepository>();

  final DownloadedSongRepository _downloads;

  RxList<Song> get songs => _downloads.completedSongs;

  Future<void> playSong(Song song) async {
    await playVisibleSongList(songs.toList(), song.id);
  }
}
