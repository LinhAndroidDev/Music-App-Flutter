import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/processed_network_image.dart';
import '../player_controller.dart';

/// Blurred cover backdrop — ServiceMusic [FragmentMusic] `RenderEffect.createBlurEffect(50, 50)`.
class PlayerSheetBackground extends StatelessWidget {
  const PlayerSheetBackground({super.key});

  /// Matches Android blur radius on [FragmentMusic.binding.imageCover].
  static const blurSigma = 10.0;

  /// Blur on a downscaled copy: cheaper and visually identical once stretched to full screen.
  static const _blurWidthPx = 200;

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final decodeWidth = math.min(screenWidth.round(), _blurWidthPx);
    // Scale sigma to the downscaled bitmap so the result matches [blurSigma] at screen size.
    final sigma = blurSigma * decodeWidth / screenWidth;

    Future<ui.Image> blur(ui.Image src) {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawImage(
        src,
        Offset.zero,
        Paint()
          ..imageFilter = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma, tileMode: TileMode.clamp),
      );
      final picture = recorder.endRecording();
      return picture.toImage(src.width, src.height).whenComplete(picture.dispose);
    }

    return Obx(() {
      final coverUrl = player.currentSong.value?.thumbnailUrl ?? '';
      if (coverUrl.isEmpty) {
        return const ColoredBox(color: AppColors.black);
      }
      // Blurred once per track instead of a full-screen ImageFiltered on every frame.
      return RepaintBoundary(
        child: ProcessedNetworkImage(
          url: coverUrl,
          decodeWidth: decodeWidth,
          process: blur,
          placeholder: const ColoredBox(color: AppColors.black),
          width: double.infinity,
          height: double.infinity,
          filterQuality: FilterQuality.low,
        ),
      );
    });
  }
}
