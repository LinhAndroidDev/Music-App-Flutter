import 'dart:async';

import 'package:get/get.dart';

import '../../data/playback/downloaded_song_repository.dart';
import '../discover/discover_binding.dart';
import '../library/library_controller.dart';
import '../profile/profile_controller.dart';
import '../zing_chart/zing_chart_binding.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    DiscoverBinding().dependencies();
    ZingChartBinding().dependencies();
    Get.lazyPut<LibraryController>(LibraryController.new, fenix: true);
    Get.lazyPut<ProfileController>(ProfileController.new, fenix: true);
    if (Get.isRegistered<DownloadedSongRepository>()) {
      unawaited(Get.find<DownloadedSongRepository>().refreshCompleted());
    }
  }
}
