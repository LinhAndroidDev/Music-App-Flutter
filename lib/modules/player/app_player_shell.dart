import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/navigation/app_navigate.dart';
import '../../core/navigation/app_navigation_route.dart';
import '../../core/playback/playback_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_bottom_bar.dart';
import '../main/main_controller.dart';
import 'music_player_coordinator.dart';
import 'music_player_sheet.dart';
import 'widgets/mini_player_bar.dart';
import 'widgets/player_sheet_overlay.dart';

/// Global full player + mini player above all GetX routes (ServiceMusic MainActivity).
class AppPlayerShell extends StatefulWidget {
  const AppPlayerShell({super.key, required this.child});

  final Widget? child;

  /// Matches [MiniPlayerBar.totalHeight] (card + margins).
  static double get miniPlayerBarHeight => MiniPlayerBar.totalHeight;

  static double mainBottomNavHeight(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom + 49;
  }

  /// Extra list padding when shell inset is not applied (legacy screens).
  static const scrollListBottomInset = 156.0;

  static double bottomContentInset(
    BuildContext context, {
    required bool showBottomBar,
    required bool showMiniBar,
  }) {
    var inset = 0.0;
    if (showBottomBar) {
      inset += mainBottomNavHeight(context);
    }
    if (showMiniBar) {
      inset += miniPlayerBarHeight;
    }
    return inset;
  }

  @override
  State<AppPlayerShell> createState() => _AppPlayerShellState();
}

class _AppPlayerShellState extends State<AppPlayerShell> {
  late final MusicPlayerCoordinator _coordinator;
  late final AppNavigationRoute _navRoute;
  late final PlaybackController _playback;
  late final MainController _main;

  @override
  void initState() {
    super.initState();
    _coordinator = Get.find<MusicPlayerCoordinator>();
    _navRoute = Get.find<AppNavigationRoute>();
    _playback = Get.find<PlaybackController>();
    _main = Get.find<MainController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fullPlayerOpen = _coordinator.isOpen.value;
      _navRoute.currentRoute.value;
      _navRoute.modalRouteCount.value;
      final showBottomBar = _navRoute.showsAppChrome;

      final playbackState = _playback.playbackState.value;
      final showMiniBar = showBottomBar &&
          !fullPlayerOpen &&
          playbackState.hasActivePlayer &&
          playbackState.currentSong != null;

      final chromeBottom = AppPlayerShell.bottomContentInset(
        context,
        showBottomBar: showBottomBar,
        showMiniBar: showMiniBar,
      );

      final mediaQuery = MediaQuery.of(context);
      final childMediaQuery = mediaQuery.copyWith(
        padding: mediaQuery.padding.copyWith(
          bottom: mediaQuery.padding.bottom + chromeBottom,
        ),
      );

      return Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: MediaQuery(
              data: childMediaQuery,
              child: ColoredBox(
                color: AppColors.background,
                child: widget.child ?? const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned.fill(
            child: PlayerSheetOverlay(
              isOpen: fullPlayerOpen,
              child: const MusicPlayerSheet(),
            ),
          ),
          if (showMiniBar)
            Positioned(
              left: 0,
              right: 0,
              bottom: showBottomBar ? AppPlayerShell.mainBottomNavHeight(context) : 0,
              child: const MiniPlayerBar(),
            ),
          if (showBottomBar)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomBottomBar(
                currentTab: _main.currentTab.value,
                onTabSelected: AppNavigate.switchMainTab,
                profilePhotoUrl: _main.profilePhotoUrl.value,
              ),
            ),
        ],
      );
    });
  }
}
