import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/song.dart';

class EditPlaylistSongRow extends StatelessWidget {
  const EditPlaylistSongRow({
    super.key,
    required this.song,
    required this.dragHandle,
  });

  final Song song;
  final Widget dragHandle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 52,
                height: 52,
                child: song.thumbnailUrl.isNotEmpty
                    ? CachedNetworkImage(imageUrl: song.thumbnailUrl, fit: BoxFit.cover)
                    : ColoredBox(
                        color: AppColors.greyLight,
                        child: Center(
                          child: AppIcon(AppAssets.icMusic, size: 24, color: AppColors.txtHint),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.nameSinger,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.txtHint),
                  ),
                ],
              ),
            ),
            dragHandle,
          ],
        ),
      ),
    );
  }
}
