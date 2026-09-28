import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../player_controller.dart';

/// Blurred cover backdrop — ServiceMusic [FragmentMusic] `RenderEffect.createBlurEffect(50, 50)`.
class PlayerSheetBackground extends StatelessWidget {
  const PlayerSheetBackground({super.key});

  /// Matches Android blur radius on [FragmentMusic.binding.imageCover].
  static const blurSigma = 10.0;

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();
    final cacheWidth = MediaQuery.sizeOf(context).width.round();

    return Obx(() {
      final coverUrl = player.currentSong.value?.thumbnailUrl ?? '';
      if (coverUrl.isEmpty) {
        return const ColoredBox(color: AppColors.black);
      }

      return ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: blurSigma,
          sigmaY: blurSigma,
          tileMode: TileMode.clamp,
        ),
        child: CachedNetworkImage(
          imageUrl: coverUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          filterQuality: FilterQuality.low,
          memCacheWidth: cacheWidth,
        ),
      );
    });
  }
}
