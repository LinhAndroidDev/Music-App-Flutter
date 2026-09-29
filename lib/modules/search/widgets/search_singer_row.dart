import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/firestore_song.dart';

class SearchSingerRow extends StatelessWidget {
  const SearchSingerRow({
    super.key,
    required this.singer,
    this.onTap,
  });

  final FirestoreSinger singer;
  final VoidCallback? onTap;

  static const _avatarSize = 52.0;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: _avatarSize,
                height: _avatarSize,
                child: singer.avatarUrl.isNotEmpty
                    ? CachedNetworkImage(imageUrl: singer.avatarUrl, fit: BoxFit.cover)
                    : Container(color: AppColors.greyLight),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                singer.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
