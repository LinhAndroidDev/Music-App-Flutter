import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/navigation/app_navigation_route.dart';
import 'music_player_coordinator.dart';
import 'music_player_sheet.dart';
import 'widgets/mini_player_bar.dart';

/// Global full player + mini player above all GetX routes (ServiceMusic MainActivity).
class AppPlayerShell extends StatelessWidget {
  const AppPlayerShell({super.key, required this.child});

  final Widget? child;

  /// Bottom nav on [AppRoute.main] — mini sits above this (see [MainPage]).
  static double mainBottomNavHeight(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom + 49;
  }

  /// Scroll padding when mini player may cover list items (ServiceMusic 156dp).
  static const scrollListBottomInset = 156.0;

  @override
  Widget build(BuildContext context) {
    final coordinator = Get.find<MusicPlayerCoordinator>();

    return Stack(
      fit: StackFit.expand,
      children: [
        child ?? const SizedBox.shrink(),
        Obx(
          () => coordinator.isOpen.value
              ? const Positioned.fill(child: MusicPlayerSheet())
              : const SizedBox.shrink(),
        ),
        Obx(() {
          final navRoute = Get.find<AppNavigationRoute>();
          navRoute.currentRoute.value;
          final onMain = navRoute.isOnMain;
          final bottom = onMain
              ? mainBottomNavHeight(context)
              : MediaQuery.paddingOf(context).bottom;
          return Positioned(
            left: 0,
            right: 0,
            bottom: bottom,
            child: const MiniPlayerBar(),
          );
        }),
      ],
    );
  }
}
