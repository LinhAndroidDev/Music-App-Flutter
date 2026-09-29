import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';

class PlaylistCoverCard extends StatelessWidget {
  const PlaylistCoverCard({
    super.key,
    required this.coverUrl,
    this.size = 180,
  });

  final String coverUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      color: AppColors.white,
      child: SizedBox(
        width: size,
        height: size,
        child: coverUrl.isNotEmpty
            ? CachedNetworkImage(imageUrl: coverUrl, fit: BoxFit.cover)
            : const ColoredBox(
                color: AppColors.greyLight,
                child: Center(
                  child: AppIcon(AppAssets.icPlaylist, size: 48, color: AppColors.txtHint),
                ),
              ),
      ),
    );
  }
}
