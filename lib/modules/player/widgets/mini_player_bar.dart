import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/navigation/app_navigate.dart';
import '../../../core/playback/playback_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../music_player_coordinator.dart';
import '../player_controller.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final playback = Get.find<PlaybackController>();
    final player = Get.find<PlayerController>();

    final playerUi = Get.find<MusicPlayerCoordinator>();

    return Obx(() {
      final state = playback.playbackState.value;
      final isFavourite = player.isFavourite.value;
      final fullPlayerOpen = playerUi.isOpen.value;
      if (!state.hasActivePlayer || state.currentSong == null) {
        return const SizedBox.shrink();
      }
      if (fullPlayerOpen) {
        return const SizedBox.shrink();
      }

      final song = state.currentSong!;
      final progress = state.durationMs > 0
          ? (state.positionMs / state.durationMs).clamp(0.0, 1.0)
          : 0.0;

      return Material(
        color: AppColors.white,
        elevation: 8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 2,
              backgroundColor: AppColors.greyLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.bgPurple),
            ),
            InkWell(
              onTap: () => AppNavigate.openPlayer(preservePlayback: true),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textBlack,
                            ),
                          ),
                          Text(
                            song.nameSinger,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.txtHint,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      onPressed: () => player.toggleFavourite(),
                      icon: AppIcon(
                        isFavourite ? AppAssets.icFavouriteFill : AppAssets.icFavouriteThin,
                        size: 28,
                        color: isFavourite ? AppColors.bgPink : AppColors.textBlack,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                      onPressed: () => playback.playPause(),
                      icon: AppIcon(
                        state.isPlaying ? AppAssets.pause : AppAssets.play,
                        size: 30,
                        color: AppColors.textBlack,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      onPressed: () => playback.dismissMiniPlayer(),
                      icon: const AppIcon(
                        AppAssets.icClose,
                        size: 25,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
