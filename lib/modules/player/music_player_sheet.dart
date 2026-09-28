import 'package:flutter/material.dart';

import '../../core/assets/app_assets.dart';
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
    final l10n = context.l10n;
    final height = MediaQuery.sizeOf(context).height;
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: _closePlayer,
                                  icon: const AppIcon(AppAssets.icBack, color: AppColors.white),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        l10n.player_play_from,
                                        style: TextStyle(
                                          color: AppColors.white.withOpacity(0.6),
                                          fontSize: 11,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      Text(
                                        l10n.nav_zingchart,
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => SongOptionsSheet.show(context),
                                  icon: const AppIcon(AppAssets.icMenu, color: AppColors.white),
                                ),
                              ],
                            ),
                          ),
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
                    const SizedBox(height: 8),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _pageIndex = i),
                        children: const [
                          PlayerSingerPage(),
                          PlayerSongPage(),
                          PlayerLyricsPage(),
                        ],
                      ),
                    ),
                    const PlayerTransportControls(),
                    const SizedBox(height: 16),
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
