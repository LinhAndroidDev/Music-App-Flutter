import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/assets/app_assets.dart';
import '../../core/playback/playback_controller.dart';
import '../../core/l10n/l10n.dart';
import '../../core/navigation/app_navigate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';
import 'widgets/player_lyrics_page.dart';
import 'widgets/player_pager_indicator.dart';
import 'widgets/player_sheet_background.dart';
import 'widgets/player_singer_page.dart';
import 'widgets/player_song_page.dart';
import 'widgets/player_transport_controls.dart';
import 'song_options_config.dart';
import 'widgets/song_options_sheet.dart';

class MusicPlayerSheet extends StatefulWidget {
  const MusicPlayerSheet({super.key});

  static const pageSinger = 0;
  static const pageSong = 1;
  static const pageLyrics = 2;

  @override
  State<MusicPlayerSheet> createState() => _MusicPlayerSheetState();
}

class _MusicPlayerSheetState extends State<MusicPlayerSheet> {
  static const _dismissDragFraction = 0.1;

  late final PageController _pageController;
  int _pageIndex = MusicPlayerSheet.pageSong;
  double _dragDy = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: MusicPlayerSheet.pageSong);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDragUpdate(double deltaDy, double maxDrag) {
    setState(() {
      _dragDy = (_dragDy + deltaDy).clamp(0.0, maxDrag);
    });
  }

  void _resetDrag() {
    if (_dragDy == 0) return;
    setState(() => _dragDy = 0);
  }

  void _maybeDismiss(double screenHeight) {
    if (_dragDy > screenHeight * _dismissDragFraction) {
      AppNavigate.closePlayer();
    } else {
      _resetDrag();
    }
  }

  void _closePlayer() => AppNavigate.closePlayer();

  @override
  Widget build(BuildContext context) {
    // Player lives in GetMaterialApp.builder (sibling of app Navigator) — nested
    // Navigator so modal sheets/dialogs from the player menu work and stack on top.
    return HeroMode(
      enabled: false,
      child: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (routeContext) => _buildPlayer(routeContext),
          );
        },
      ),
    );
  }

  Widget _buildPlayer(BuildContext routeContext) {
    final l10n = routeContext.l10n;
    final height = MediaQuery.sizeOf(routeContext).height;
    final maxDrag = height;

    return Transform.translate(
      offset: Offset(0, _dragDy),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: Material(
          color: AppColors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const PlayerSheetBackground(),
              SafeArea(
                child: Column(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragUpdate: (d) => _onDragUpdate(d.delta.dy, maxDrag),
                      onVerticalDragEnd: (_) => _maybeDismiss(height),
                      onVerticalDragCancel: _resetDrag,
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 35,
                                  height: 35,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: _closePlayer,
                                    icon: const AppIcon(
                                      AppAssets.icBack,
                                      size: 35,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        l10n.player_play_from,
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        l10n.nav_zingchart,
                                        style: const TextStyle(
                                          color: AppColors.textWhite,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 35,
                                  height: 35,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    alignment: Alignment.centerRight,
                                    onPressed: () {
                                      final song = Get.find<PlaybackController>()
                                          .playbackState
                                          .value
                                          .currentSong;
                                      if (song == null) return;
                                      SongOptionsSheet.show(
                                        routeContext,
                                        song: song,
                                        config: SongOptionsConfig.player,
                                      );
                                    },
                                    icon: const AppIcon(
                                      AppAssets.icMenu,
                                      size: 25,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                    PlayerPagerIndicator(
                      pageCount: 3,
                      currentPage: _pageIndex,
                      onTap: (i) {
                        _pageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOut,
                        );
                      },
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _pageIndex = i),
                        children: [
                          const PlayerSingerPage(),
                          const PlayerSongPage(),
                          PlayerLyricsPage(
                            isPageVisible: _pageIndex == MusicPlayerSheet.pageLyrics,
                          ),
                        ],
                      ),
                    ),
                    const PlayerTransportControls(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
