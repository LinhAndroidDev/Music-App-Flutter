import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/playback/playback_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../player_controller.dart';

class PlayerSongPage extends StatelessWidget {
  const PlayerSongPage({super.key});

  static const _thumbSize = 300.0;
  static const _actionIconSize = 25.0;

  @override
  Widget build(BuildContext context) {
    final playback = Get.find<PlaybackController>();
    final player = Get.find<PlayerController>();
    final thumbSize = math.min(MediaQuery.sizeOf(context).width - 40, _thumbSize);

    return Obx(() {
      final song = playback.playbackState.value.currentSong;
      final isFavourite = player.isFavourite.value;
      if (song == null) {
        return const Center(child: SizedBox.shrink());
      }

      return Column(
        children: [
          const SizedBox(height: 30),
          SizedBox(
            width: thumbSize,
            height: thumbSize,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: song.thumbnailUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: song.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.purpleDark1),
                      errorWidget: (_, __, ___) => Container(color: AppColors.purpleDark1),
                    )
                  : Container(color: AppColors.purpleDark1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: () => Share.share('${song.title} — ${song.nameSinger}'),
                  icon: const AppIcon(
                    AppAssets.icShare,
                    size: _actionIconSize,
                    color: AppColors.white,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Text(
                          song.title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          song.nameSinger,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: () => player.toggleFavourite(),
                  icon: AppIcon(
                    isFavourite ? AppAssets.icFavouriteFill : AppAssets.icFavouriteThin,
                    size: _actionIconSize,
                    color: isFavourite ? AppColors.bgPink : AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      );
    });
  }
}
