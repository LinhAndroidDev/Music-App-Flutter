import 'package:get/get.dart';

import 'followed_singers_controller.dart';

class FollowedSingersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(FollowedSingersController.new);
  }
}
