import 'package:get/get.dart';

import '../discover/discover_binding.dart';
import '../library/library_controller.dart';
import '../profile/profile_controller.dart';
import 'main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(MainController.new, fenix: true);
    DiscoverBinding().dependencies();
    Get.lazyPut<LibraryController>(LibraryController.new, fenix: true);
    Get.lazyPut<ProfileController>(ProfileController.new, fenix: true);
  }
}
