import 'package:get/get.dart';

import 'app_route.dart';

/// Current GetX route name — updated via routingCallback for global UI (mini player inset).
class AppNavigationRoute extends GetxService {
  final currentRoute = ''.obs;

  void updateRoute(String? route) {
    if (route != null && route.isNotEmpty) {
      currentRoute.value = route;
    }
  }

  bool get isOnMain => currentRoute.value == AppRoute.main;
}
