import 'package:get/get.dart';

import 'favourite_song_controller.dart';

class FavouriteSongBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(FavouriteSongController.new);
  }
}
