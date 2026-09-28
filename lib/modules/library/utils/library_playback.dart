import 'package:get/get.dart';

import '../../../core/navigation/app_navigate.dart';
import '../../../core/playback/playback_controller.dart';
import '../../../data/models/song.dart';

Future<void> playVisibleSongList(List<Song> songs, String songId) async {
  if (songs.isEmpty || songId.isEmpty) return;
  try {
    AppNavigate.presentPlayerUi();
    final playback = Get.find<PlaybackController>();
    final ok = await playback.playFromVisibleList(songs, songId);
    if (!ok) {
      AppNavigate.closePlayer();
      Get.snackbar('', 'Không thể phát bài hát này', snackPosition: SnackPosition.BOTTOM);
    }
  } on StateError catch (e) {
    AppNavigate.closePlayer();
    Get.snackbar('', e.message, snackPosition: SnackPosition.BOTTOM);
  } catch (_) {
    AppNavigate.closePlayer();
    Get.snackbar('', 'Không thể phát bài hát này', snackPosition: SnackPosition.BOTTOM);
  }
}
