import 'dart:async';

import 'package:get/get.dart';

import '../../core/base/base_controller.dart';
import '../../core/navigation/app_navigate.dart';
import '../../core/playback/playback_controller.dart';

class SplashController extends BaseController {
  var _leaving = false;

  /// Called when splash entrance animations finish (mirrors ad load callback on Android).
  void onEntranceComplete() {
    if (_leaving) return;
    _leaving = true;
    unawaited(_enterMain());
  }

  Future<void> _enterMain() async {
    if (Get.isRegistered<PlaybackController>()) {
      await Get.find<PlaybackController>().ensureReady();
    }
    AppNavigate.toMain();
  }
}
