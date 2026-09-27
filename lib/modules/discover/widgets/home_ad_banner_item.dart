import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'banner_carousel_metrics.dart';

class HomeAdBannerItem extends StatelessWidget {
  const HomeAdBannerItem({
    super.key,
    required this.imageUrl,
    required this.update,
    required this.detail,
  });

  final String imageUrl;
  final String update;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: BannerCarouselMetrics.horizontalScreenInset,
      ),
      child: SizedBox(
        height: BannerCarouselMetrics.viewportHeight,
        child: HomeAdBannerCard(
          imageUrl: imageUrl,
          update: update,
          detail: detail,
        ),
      ),
    );
  }
}

class HomeAdBannerCard extends StatelessWidget {
  const HomeAdBannerCard({
    super.key,
    required this.imageUrl,
    required this.update,
    required this.detail,
  });

  final String imageUrl;
  final String update;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isNotEmpty)
            CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover)
          else
            const ColoredBox(color: AppColors.greyLight),
          if (update.isNotEmpty)
            Positioned(
              left: 15,
              top: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.txtGreyBlur,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  update.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textBlack,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 30, 15, 10),
                child: Text(
                  detail,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
