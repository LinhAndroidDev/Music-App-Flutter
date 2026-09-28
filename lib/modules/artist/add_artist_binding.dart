import 'package:get/get.dart';

import 'add_artist_controller.dart';

class AddArtistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(AddArtistController.new);
  }
}
