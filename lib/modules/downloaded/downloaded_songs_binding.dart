import 'package:get/get.dart';

import 'downloaded_songs_controller.dart';

class DownloadedSongsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(DownloadedSongsController.new);
  }
}
