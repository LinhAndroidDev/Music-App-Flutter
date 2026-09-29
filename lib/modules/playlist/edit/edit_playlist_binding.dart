import 'package:get/get.dart';

import 'edit_playlist_controller.dart';

class EditPlaylistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(EditPlaylistController.new);
  }
}
