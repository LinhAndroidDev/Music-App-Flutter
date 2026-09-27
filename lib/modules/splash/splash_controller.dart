import '../../core/base/base_controller.dart';
import '../../core/navigation/app_navigate.dart';

class SplashController extends BaseController {
  var _leaving = false;

  /// Called when splash entrance animations finish (mirrors ad load callback on Android).
  void onEntranceComplete() {
    if (_leaving) return;
    _leaving = true;
    AppNavigate.toMain();
  }
}
