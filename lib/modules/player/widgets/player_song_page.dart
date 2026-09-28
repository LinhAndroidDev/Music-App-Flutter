import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../player_controller.dart';
import 'rotating_player_cover.dart';

class PlayerSongPage extends StatelessWidget {
  const PlayerSongPage({super.key});

  static const _thumbSize = 300.0;
  static const _actionIconSize = 25.0;

  @override
  Widget build(BuildContext context) {
    final thumbSize = math.min(MediaQuery.sizeOf(context).width - 40, _thumbSize);
    final cachePx = (thumbSize * MediaQuery.devicePixelRatioOf(context)).round();

    final player = Get.find<PlayerController>();

    return Column(
      children: [
        const SizedBox(height: 30),
        Obx(() {
          final song = player.currentSong.value;
          if (song == null) return const SizedBox.shrink();
          return RotatingPlayerCover(
            key: ValueKey(song.id),
            songId: song.id,
            thumbnailUrl: song.thumbnailUrl,
            size: thumbSize,
            cacheSizePx: cachePx,
          );
        }),
        Obx(() {
          final song = player.currentSong.value;
          if (song == null) return const SizedBox.shrink();
          final isFavourite = player.isFavourite.value;
          return Padding(
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
          );
        }),
        const Spacer(),
      ],
    );
  }
}
