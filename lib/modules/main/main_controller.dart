import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../core/base/base_controller.dart';
import '../../core/navigation/app_navigate.dart';
import '../../core/navigation/app_route.dart';
import '../../core/playback/playback_controller.dart';
import '../../data/services/auth_repository.dart';

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
    syncTabFromRouteParameters();

    if (Get.isRegistered<AuthRepository>()) {
      final auth = Get.find<AuthRepository>();
      profilePhotoUrl.value = auth.currentUser.value?.photoUrl;
      ever(auth.currentUser, (user) {
        profilePhotoUrl.value = user?.photoUrl;
      });
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _closePlayerIfNothingPlaying();
    });
  }

  void _closePlayerIfNothingPlaying() {
    if (!Get.isRegistered<PlaybackController>()) return;
    final state = Get.find<PlaybackController>().playbackState.value;
    if (!state.hasActivePlayer || state.currentSong == null) {
      AppNavigate.closePlayer();
    }
  }

  void syncTabFromRouteParameters() {
    final tabParam = Get.parameters[AppRouteParam.tab];
    if (tabParam == null) return;
    final parsed = int.tryParse(tabParam);
    if (parsed != null && parsed >= AppTab.library && parsed <= AppTab.profile) {
      currentTab.value = parsed;
    }
  }

  @override
  void selectTab(int index) {
    if (index < AppTab.library || index > AppTab.profile) return;
    currentTab.value = index;
  }
}
