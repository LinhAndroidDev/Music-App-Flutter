import 'package:get/get.dart';

import 'singer_detail_controller.dart';

class SingerDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(SingerDetailController.new);
  }
}
