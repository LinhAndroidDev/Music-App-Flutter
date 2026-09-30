import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/followed_singer.dart';
import '../singer_shared_element.dart';
import 'singer_hero_widgets.dart';

class FollowedSingerRow extends StatelessWidget {
  const FollowedSingerRow({
    super.key,
    required this.singer,
    this.onTap,
  });

  final FollowedSinger singer;
  final VoidCallback? onTap;

  static const _avatarSize = 52.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SingerHeroAvatar(
              tag: SingerSharedElement.avatarTag(singer.id),
              avatarUrl: singer.avatarUrl,
              size: _avatarSize,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingerHeroName(
                    tag: SingerSharedElement.nameTag(singer.id),
                    title: singer.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l10n.search_section_artists,
                    style: const TextStyle(fontSize: 12, color: AppColors.txtHint),
                  ),
                ],
              ),
            ),
            Transform.rotate(
              angle: 3.14159,
              child: const AppIcon(AppAssets.icBackThin, size: 20, color: AppColors.txtHint),
            ),
          ],
        ),
      ),
    );
  }
}

class AddArtistFooterRow extends StatelessWidget {
  const AddArtistFooterRow({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const AppIcon(AppAssets.icAddPlaylist, size: 24, color: AppColors.bgPurple),
            const SizedBox(width: 14),
            Text(
              l10n.artist_add,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
