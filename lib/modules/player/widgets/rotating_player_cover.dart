import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Circular cover with continuous rotation (ServiceMusic [CustomAnimator.rotationImage]).
class RotatingPlayerCover extends StatefulWidget {
  const RotatingPlayerCover({
    super.key,
    required this.songId,
    required this.thumbnailUrl,
    required this.size,
    required this.cacheSizePx,
  });

  final String songId;
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
  void didUpdateWidget(RotatingPlayerCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songId != widget.songId) {
      _controller
        ..reset()
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      shadowColor: Colors.black54,
      shape: const CircleBorder(),
      color: Colors.transparent,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: RepaintBoundary(
          child: RotationTransition(
            turns: _controller,
            child: ClipOval(
              child: _CoverImage(
                thumbnailUrl: widget.thumbnailUrl,
                size: widget.size,
                cacheSizePx: widget.cacheSizePx,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({
    required this.thumbnailUrl,
    required this.size,
    required this.cacheSizePx,
  });

  final String thumbnailUrl;
  final double size;
  final int cacheSizePx;

  @override
  Widget build(BuildContext context) {
    if (thumbnailUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        color: AppColors.greyLight,
      );
    }
    return CachedNetworkImage(
      imageUrl: thumbnailUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      memCacheWidth: cacheSizePx,
      memCacheHeight: cacheSizePx,
      filterQuality: FilterQuality.medium,
      placeholder: (_, __) => Container(color: AppColors.greyLight),
      errorWidget: (_, __, ___) => Container(color: AppColors.greyLight),
    );
  }
}
