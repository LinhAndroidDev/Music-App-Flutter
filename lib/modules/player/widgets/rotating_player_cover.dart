import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/processed_network_image.dart';

/// Circular cover with continuous rotation (ServiceMusic [CustomAnimator.rotationImage]).
class RotatingPlayerCover extends StatefulWidget {
  const RotatingPlayerCover({
    super.key,
    required this.thumbnailUrl,
    required this.size,
    required this.cacheSizePx,
  });

  final String thumbnailUrl;
  final double size;
  final int cacheSizePx;

  static const rotationDuration = Duration(milliseconds: 25000);

  @override
  State<RotatingPlayerCover> createState() => _RotatingPlayerCoverState();
}

class _RotatingPlayerCoverState extends State<RotatingPlayerCover>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: RotatingPlayerCover.rotationDuration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Bakes the circular crop into the bitmap once, so each frame only rotates a texture
  /// (no per-frame clip) — the Flutter equivalent of the hardware layer used on Android.
  Future<ui.Image> _toCircle(ui.Image src) {
    final px = widget.cacheSizePx;
    final side = math.min(src.width, src.height).toDouble();
    final srcRect = Rect.fromCenter(
      center: Offset(src.width / 2, src.height / 2),
      width: side,
      height: side,
    );
    final dstRect = Rect.fromLTWH(0, 0, px.toDouble(), px.toDouble());

    final recorder = ui.PictureRecorder();
    Canvas(recorder)
      ..clipPath(Path()..addOval(dstRect))
      ..drawImageRect(src, srcRect, dstRect, Paint()..filterQuality = FilterQuality.medium);
    final picture = recorder.endRecording();
    return picture.toImage(px, px).whenComplete(picture.dispose);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final placeholder = SizedBox(
      width: size,
      height: size,
      child: const DecoratedBox(
        decoration: BoxDecoration(color: AppColors.greyLight, shape: BoxShape.circle),
      ),
    );

    return Material(
      elevation: 10,
      shadowColor: Colors.black54,
      shape: const CircleBorder(),
      color: Colors.transparent,
      child: SizedBox(
        width: size,
        height: size,
        // Isolates the per-frame rotation from the rest of the sheet.
        child: RepaintBoundary(
          child: RotationTransition(
            turns: _controller,
            child: widget.thumbnailUrl.isEmpty
                ? placeholder
                : ProcessedNetworkImage(
                    url: widget.thumbnailUrl,
                    decodeWidth: widget.cacheSizePx,
                    process: _toCircle,
                    placeholder: placeholder,
                    width: size,
                    height: size,
                  ),
          ),
        ),
      ),
    );
  }
}
