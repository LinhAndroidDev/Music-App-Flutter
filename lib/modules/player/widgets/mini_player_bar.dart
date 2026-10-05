import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/navigation/app_navigate.dart';
import '../../../core/navigation/app_navigation_route.dart';
import '../../../core/playback/playback_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/chrome_top_shadow.dart';
import '../../../core/widgets/marquee_text.dart';
import '../../../data/models/song.dart';
import '../music_player_coordinator.dart';
import '../player_controller.dart';

/// Bottom mini player — layout parity with ServiceMusic `activity_main` / `bottomPlay`.
class MiniPlayerBar extends StatefulWidget {
  const MiniPlayerBar({super.key});

  /// 15dp card top inset + 50dp card body + 10dp margin above bottom nav.
  static const totalHeight = 75.0;

  @override
  State<MiniPlayerBar> createState() => _MiniPlayerBarState();
}

class _MiniPlayerBarState extends State<MiniPlayerBar> {
  static const _cardTopInset = 15.0;
  static const _cardBodyHeight = 50.0;
  static const _contentHeight = _cardTopInset + _cardBodyHeight;
  static const _outerMarginH = 10.0;
  static const _outerMarginBottom = 10.0;

  PageController? _pageController;
  int _pageControllerLength = 0;
  bool _syncingPageFromPlayback = false;

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _syncPageController(int count, int index) {
    if (count <= 0) return;
    final safeIndex = index.clamp(0, count - 1);
    if (_pageController == null || _pageControllerLength != count) {
      _pageController?.dispose();
      _pageController = PageController(initialPage: safeIndex);
      _pageControllerLength = count;
      return;
    }
    final page = _pageController!.hasClients ? (_pageController!.page?.round() ?? safeIndex) : safeIndex;
    if (page != safeIndex) {
      _syncingPageFromPlayback = true;
      _pageController!.jumpToPage(safeIndex);
      _syncingPageFromPlayback = false;
    }
  }

  Widget _songInfoPage(Song song) {
    // ServiceMusic ViewPager row is 38dp; tight line metrics avoid 1px Column overflow.
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MarqueeText(
            song.title,
            style: const TextStyle(
              color: AppColors.textBlack,
              fontSize: 13,
              height: 1.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            song.nameSinger,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.txtHint,
              fontSize: 12,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  void _openFullPlayer() {
    AppNavigate.openPlayer(preservePlayback: true);
  }

  void _onMiniPlayerPageChanged(PlaybackController playback, int index, int queueIndex) {
    if (_syncingPageFromPlayback || index == queueIndex) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      playback.playSongAtIndex(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final playback = Get.find<PlaybackController>();
    final player = Get.find<PlayerController>();
    final playerUi = Get.find<MusicPlayerCoordinator>();

    return Obx(() {
      final navRoute = Get.find<AppNavigationRoute>();
      navRoute.currentRoute.value;
      final state = playback.playbackState.value;
      final isFavourite = player.isFavourite.value;
      final fullPlayerOpen = playerUi.isOpen.value;

      if (!navRoute.showsAppChrome) {
        return const SizedBox.shrink();
      }
      if (!state.hasActivePlayer || state.currentSong == null) {
        return const SizedBox.shrink();
      }
      if (fullPlayerOpen) {
        return const SizedBox.shrink();
      }

      final song = state.currentSong!;
      final playlist = playback.getPlaylist();
      final queueIndex = state.queueIndex.clamp(0, playlist.isEmpty ? 0 : playlist.length - 1);
      if (playlist.isNotEmpty) {
        _syncPageController(playlist.length, queueIndex);
      }

      final progress = state.durationMs > 0
          ? (state.positionMs / state.durationMs).clamp(0.0, 1.0)
          : 0.0;

      return GestureDetector(
        onTap: _openFullPlayer,
        behavior: HitTestBehavior.translucent,
        child: Padding(
              padding: const EdgeInsets.fromLTRB(_outerMarginH, 0, _outerMarginH, _outerMarginBottom),
              child: SizedBox(
                height: _contentHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: _cardTopInset,
                      child: ChromeRoundedCardShadow(
                        height: _cardBodyHeight,
                        borderRadius: 10,
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 70),
                                    Expanded(
                                      child: playlist.isEmpty || _pageController == null
                                          ? _songInfoPage(song)
                                          : PageView.builder(
                                              controller: _pageController,
                                              itemCount: playlist.length,
                                              onPageChanged: (i) => _onMiniPlayerPageChanged(
                                                playback,
                                                i,
                                                state.queueIndex,
                                              ),
                                              itemBuilder: (_, i) => _songInfoPage(playlist[i]),
                                            ),
                                    ),
                                    const SizedBox(width: 5),
                                    InkWell(
                                      onTap: () => player.toggleFavourite(),
                                      customBorder: const CircleBorder(),
                                      child: AppIcon(
                                        isFavourite ? AppAssets.icFavouriteFill : AppAssets.icFavouriteThin,
                                        size: 28,
                                        color: isFavourite ? AppColors.bgPink : AppColors.textBlack,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    InkWell(
                                      onTap: () => playback.playPause(),
                                      customBorder: const CircleBorder(),
                                      child: AppIcon(
                                        state.isPlaying ? AppAssets.pause : AppAssets.play,
                                        size: 30,
                                        color: AppColors.textBlack,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: InkWell(
                                        onTap: () => playback.dismissMiniPlayer(),
                                        customBorder: const CircleBorder(),
                                        child: const AppIcon(
                                          AppAssets.icClose,
                                          size: 25,
                                          color: AppColors.textBlack,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 2,
                                backgroundColor: AppColors.greyLight,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.bgPurple),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 0,
                      child: Material(
                        elevation: 8,
                        shadowColor: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: song.thumbnailUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: song.thumbnailUrl,
                                  fit: BoxFit.cover,
                                )
                              : Container(color: AppColors.purpleDark1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ),
      );
    });
  }
}
