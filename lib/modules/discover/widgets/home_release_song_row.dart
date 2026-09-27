import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/song.dart';
import '../utils/format_duration.dart';

class HomeReleaseSongRow extends StatelessWidget {
  const HomeReleaseSongRow({
    super.key,
    required this.song,
    this.onTap,
    this.onMore,
  });

  final Song song;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: SizedBox(
                width: 60,
                height: 60,
                child: song.thumbnailUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: song.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    song.nameSinger,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.txtHint,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatSongDuration(song.durationSec),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.txtHint,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 60,
              child: Center(
                child: InkWell(
                  onTap: onMore,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 20, right: 10),
                    child: AppIcon(
                      AppAssets.icMenu,
                      size: 20,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return const ColoredBox(
      color: AppColors.greyLight,
      child: Center(
        child: AppIcon(AppAssets.icMusic, size: 28, color: AppColors.txtHint),
      ),
    );
  }
}
