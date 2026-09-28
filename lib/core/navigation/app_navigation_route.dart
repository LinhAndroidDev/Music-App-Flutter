import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../modules/main/main_controller.dart';
import '../../modules/player/music_player_coordinator.dart';
import 'app_route.dart';

/// Current GetX route name — updated via routingCallback for global UI (mini player inset).
class AppNavigationRoute extends GetxService {
  final currentRoute = AppRoute.splash.obs;

  String? _pendingRoute;
  bool _routeUpdateScheduled = false;

  /// Routes that hide bottom bar and mini player (ServiceMusic exclusions).
  static const chromeHiddenRoutes = {
    AppRoute.splash,
    AppRoute.addArtist,
  };

  static bool chromeAllowedForRoute(String route) {
    if (route.isEmpty) return false;
    return !chromeHiddenRoutes.contains(route);
  }

  /// GetX [routingCallback] can run while the navigator is building — defer Rx updates.
  void updateRoute(String? route) {
    if (route == null || route.isEmpty) return;
    _pendingRoute = route;
    if (_routeUpdateScheduled) return;
    _routeUpdateScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _routeUpdateScheduled = false;
      final next = _pendingRoute;
      _pendingRoute = null;
      if (next == null || next.isEmpty) return;
      if (currentRoute.value != next) {
        currentRoute.value = next;
      }
      _syncMainTabIfNeeded(next);
    });
  }

  void _syncMainTabIfNeeded(String route) {
    if (route == AppRoute.main && Get.isRegistered<MainController>()) {
      Get.find<MainController>().syncTabFromRouteParameters();
    }
  }

  bool get isOnMain => currentRoute.value == AppRoute.main;

  /// Bottom bar + mini player chrome (hidden on splash, add artist, full player).
  bool get showsAppChrome {
    if (!chromeAllowedForRoute(currentRoute.value)) return false;
    if (Get.isRegistered<MusicPlayerCoordinator>() &&
        Get.find<MusicPlayerCoordinator>().isOpen.value) {
      return false;
    }
    return true;
  }
}
