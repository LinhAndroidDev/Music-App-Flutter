import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/firestore_song.dart';

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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Stack(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: singer.avatarUrl.isNotEmpty
                      ? CachedNetworkImage(imageUrl: singer.avatarUrl, fit: BoxFit.cover)
                      : Container(color: AppColors.greyLight),
                ),
              ),
              if (selected)
                const Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.bgPurple,
                    child: AppIcon(AppAssets.icPersonChecked, size: 14, color: AppColors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            singer.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textBlack),
          ),
        ],
      ),
    );
  }
}
