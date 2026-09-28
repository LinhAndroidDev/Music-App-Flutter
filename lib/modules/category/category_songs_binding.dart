import 'package:get/get.dart';

import 'category_songs_controller.dart';

class CategorySongsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(CategorySongsController.new);
  }
}
