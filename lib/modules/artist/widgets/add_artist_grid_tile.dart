import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/firestore_song.dart';

/// Matches ServiceMusic [item_add_artist.xml].
class AddArtistGridTile extends StatelessWidget {
  const AddArtistGridTile({
    super.key,
    required this.singer,
    required this.selected,
    required this.onTap,
  });

  final FirestoreSinger singer;
  final bool selected;
  final VoidCallback onTap;

  static const _avatarSize = 96.0;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
        child: Column(
          children: [
            SizedBox(
              width: _avatarSize,
              height: _avatarSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: _avatarSize,
                    height: _avatarSize,
                    padding: const EdgeInsets.all(3),
                    decoration: selected
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.purple1, width: 2),
                          )
                        : null,
                    child: ClipOval(
                      child: singer.avatarUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: singer.avatarUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Container(color: AppColors.greyLight),
                    ),
                  ),
                  if (selected)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: AppColors.purple1,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const AppIcon(
                          AppAssets.icCheck,
                          size: 14,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              singer.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textBlack),
            ),
          ],
        ),
      ),
    );
  }
}
