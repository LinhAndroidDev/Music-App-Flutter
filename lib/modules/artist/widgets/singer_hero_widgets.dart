import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../playlist/widgets/playlist_hero_widgets.dart';

/// Hero wrapper for circular singer avatar (list ↔ detail).
class SingerHeroAvatar extends StatelessWidget {
  const SingerHeroAvatar({
    super.key,
    required this.tag,
    required this.avatarUrl,
    required this.size,
  });

  final String tag;
  final String avatarUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      createRectTween: (begin, end) => MaterialRectCenterArcTween(begin: begin, end: end),
      child: Material(
        color: AppColors.greyLight,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: size,
          height: size,
          child: avatarUrl.isNotEmpty
              ? CachedNetworkImage(imageUrl: avatarUrl, fit: BoxFit.cover)
              : null,
        ),
      ),
    );
  }
}

/// Hero wrapper for singer name (list ↔ detail).
typedef SingerHeroName = PlaylistHeroTitle;
