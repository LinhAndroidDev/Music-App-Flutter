import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';

class SingerFollowPlayButtons extends StatelessWidget {
  const SingerFollowPlayButtons({
    super.key,
    required this.isFollowed,
    required this.onFollow,
    required this.onPlay,
    this.enabled = true,
    this.compactness = 0,
    this.horizontalPadding = 24,
  });

  final bool isFollowed;
  final VoidCallback onFollow;
  final VoidCallback onPlay;
  final bool enabled;

  /// 0 = expanded header, 1 = fully collapsed (smaller label + padding).
  final double compactness;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = compactness.clamp(0.0, 1.0);
    final fontSize = lerpDouble(15, 11, t)!;
    final verticalPad = lerpDouble(10, 5, t)!;
    final horizontalPad = lerpDouble(12, 8, t)!;
    final gap = lerpDouble(16, 6, t)!;
    final radius = lerpDouble(25, 14, t)!;
    final followFlex = lerpDouble(10, 13, t)!.round();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          Expanded(
            flex: followFlex,
            child: Material(
              color: isFollowed ? AppColors.purple1 : AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
                side: isFollowed
                    ? BorderSide.none
                    : const BorderSide(color: AppColors.grey1, width: 1),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(radius),
                onTap: enabled ? onFollow : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: verticalPad,
                    horizontal: horizontalPad,
                  ),
                  child: Center(
                    child: Text(
                      isFollowed ? l10n.artist_following : l10n.artist_follow,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: isFollowed ? AppColors.white : AppColors.textBlack,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            flex: 10,
            child: Material(
              color: AppColors.purple1,
              borderRadius: BorderRadius.circular(radius),
              child: InkWell(
                borderRadius: BorderRadius.circular(radius),
                onTap: enabled ? onPlay : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: verticalPad,
                    horizontal: horizontalPad,
                  ),
                  child: Center(
                    child: Text(
                      l10n.artist_play,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: fontSize, color: AppColors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
