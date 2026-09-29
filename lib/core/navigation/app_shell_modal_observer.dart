import 'package:flutter/material.dart';

import 'app_navigation_route.dart';

/// Tracks modal routes (bottom sheets, dialogs) on the root GetX navigator so
/// [AppPlayerShell] can hide mini player / bottom bar while they are open.
final class AppShellModalObserver extends NavigatorObserver {
  AppShellModalObserver(this._navigationRoute);

  final AppNavigationRoute _navigationRoute;

  void _adjust(int delta) {
    final next = (_navigationRoute.modalRouteCount.value + delta).clamp(0, 32);
    if (next != _navigationRoute.modalRouteCount.value) {
      _navigationRoute.modalRouteCount.value = next;
    }
  }

  static bool _isShellModal(Route<dynamic> route) => route is PopupRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_isShellModal(route)) _adjust(1);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_isShellModal(route)) _adjust(-1);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_isShellModal(route)) _adjust(-1);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null && _isShellModal(oldRoute)) _adjust(-1);
    if (newRoute != null && _isShellModal(newRoute)) _adjust(1);
  }
}
