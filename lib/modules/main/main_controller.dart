import 'package:get/get.dart';

import '../../core/base/base_controller.dart';
import '../../core/navigation/app_route.dart';

/// Used by [AppNavigate.switchMainTab] when [AppRoute.main] is active.
abstract interface class MainTabController {
  void selectTab(int index);
}

class MainController extends BaseController implements MainTabController {
  final currentTab = AppTab.discover.obs;
  final profilePhotoUrl = RxnString();

  @override
  void onInit() {
    super.onInit();
    final tabParam = Get.parameters[AppRouteParam.tab];
    if (tabParam != null) {
      final parsed = int.tryParse(tabParam);
      if (parsed != null && parsed >= AppTab.library && parsed <= AppTab.profile) {
        currentTab.value = parsed;
      }
    }
  }

  @override
  void selectTab(int index) {
    if (index < AppTab.library || index > AppTab.profile) return;
    currentTab.value = index;
  }
}
