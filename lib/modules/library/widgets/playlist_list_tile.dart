import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/user_playlist.dart';

class PlaylistListTile extends StatelessWidget {
  const PlaylistListTile({
    super.key,
    required this.playlist,
    required this.metaText,
    this.onTap,
  });

  final UserPlaylist playlist;
  final String metaText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56,
                height: 56,
                child: playlist.coverUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: playlist.coverUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _coverFallback(),
                      )
                    : _coverFallback(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    metaText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.txtHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverFallback() {
    return const ColoredBox(
      color: AppColors.greyLight,
      child: Center(
        child: AppIcon(AppAssets.icPlaylist, size: 28, color: AppColors.txtHint),
      ),
    );
  }
}
