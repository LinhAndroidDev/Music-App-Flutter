import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/song.dart';

class ZingChartSuggestedRow extends StatelessWidget {
  const ZingChartSuggestedRow({
    super.key,
    required this.song,
    required this.onTap,
    required this.onDismiss,
  });

  final Song song;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 0, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: song.thumbnailUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: song.thumbnailUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _thumbPlaceholder(),
                          )
                        : _thumbPlaceholder(),
                  ),
                ),
                const SizedBox(width: 5),
                Column(
                  children: [
                    const Text(
                      '•',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                    Text(
                      l10n.zingchart_suggested,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 5),
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
                          color: AppColors.textWhite,
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
                    ],
                  ),
                ),
                InkWell(
                  onTap: onDismiss,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 15, 8),
                    child: AppIcon(AppAssets.icRemove, size: 23, color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
          child: Divider(height: 0.3, color: AppColors.greyBlur.withOpacity(0.5)),
        ),
      ],
    );
  }

  Widget _thumbPlaceholder() {
    return const ColoredBox(
      color: AppColors.greyLight,
      child: Center(
        child: AppIcon(AppAssets.icMusic, size: 24, color: AppColors.txtHint),
      ),
    );
  }
}
