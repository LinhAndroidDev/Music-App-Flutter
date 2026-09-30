import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';

/// Hero wrapper for playlist cover (list ↔ detail shared element).
class PlaylistHeroCover extends StatelessWidget {
  const PlaylistHeroCover({
    super.key,
    required this.tag,
    required this.coverUrl,
    required this.size,
    this.elevation = 0,
  });

  final String tag;
  final String coverUrl;
  final double size;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      createRectTween: (begin, end) => MaterialRectCenterArcTween(begin: begin, end: end),
      child: Material(
        color: AppColors.white,
        elevation: elevation,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: size,
          height: size,
          child: coverUrl.isNotEmpty
              ? CachedNetworkImage(imageUrl: coverUrl, fit: BoxFit.cover)
              : const ColoredBox(
                  color: AppColors.greyLight,
                  child: Center(
                    child: AppIcon(AppAssets.icPlaylist, size: 28, color: AppColors.txtHint),
                  ),
                ),
        ),
      ),
    );
  }
}

/// Hero wrapper for playlist title (list ↔ detail shared element).
class PlaylistHeroTitle extends StatelessWidget {
  const PlaylistHeroTitle({
    super.key,
    required this.tag,
    required this.title,
    required this.style,
    this.textAlign = TextAlign.start,
  });

  final String tag;
  final String title;
  final TextStyle style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      createRectTween: (begin, end) => MaterialRectCenterArcTween(begin: begin, end: end),
      child: Material(
        color: Colors.transparent,
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
          style: style,
        ),
      ),
    );
  }
}
