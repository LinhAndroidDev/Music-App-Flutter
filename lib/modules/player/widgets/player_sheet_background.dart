import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../player_controller.dart';

/// Blurred-style player backdrop; rebuilds only when [PlayerController.currentSong] changes.
class PlayerSheetBackground extends StatelessWidget {
  const PlayerSheetBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();
    return Obx(() {
      final coverUrl = player.currentSong.value?.thumbnailUrl ?? '';
      return Stack(
        fit: StackFit.expand,
        children: [
          if (coverUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: coverUrl,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
            ),
          Container(color: AppColors.black.withOpacity(0.62)),
        ],
      );
    });
  }
}
