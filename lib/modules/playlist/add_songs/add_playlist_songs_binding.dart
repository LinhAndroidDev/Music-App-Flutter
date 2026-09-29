import 'package:get/get.dart';

import 'add_playlist_songs_controller.dart';

class AddPlaylistSongsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(AddPlaylistSongsController.new);
  }
}
