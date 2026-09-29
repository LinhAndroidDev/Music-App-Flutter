import 'package:get/get.dart';

import '../../../core/navigation/app_navigate.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/playback/playback_controller.dart';
import '../../../data/models/song.dart';

Future<void> playVisibleSongList(List<Song> songs, String songId) async {
  if (songs.isEmpty || songId.isEmpty) return;
  try {
    final playback = Get.find<PlaybackController>();
    final ok = await playback.playFromVisibleList(songs, songId);
    if (!ok) {
      showAppToast('Không thể phát bài hát này', category: AppToastCategory.playback);
      return;
    }
    // ServiceMusic: playFromVisibleList then MusicPlayerLauncher.open (UI after queue + state).
    AppNavigate.presentPlayerUi();
  } on StateError catch (e) {
    AppNavigate.closePlayer();
    showAppToast(e.message, category: AppToastCategory.playback);
  } catch (_) {
    AppNavigate.closePlayer();
    showAppToast('Không thể phát bài hát này', category: AppToastCategory.playback);
  }
}
