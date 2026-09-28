import 'package:get/get.dart';

import '../../data/lyrics/song_lyrics_loader.dart';
import 'player_controller.dart';

class PlayerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SongLyricsLoader>()) {
      Get.put(SongLyricsLoader(), permanent: true);
    }
    if (!Get.isRegistered<PlayerController>()) {
      Get.put(PlayerController(), permanent: true);
    }
  }
}
