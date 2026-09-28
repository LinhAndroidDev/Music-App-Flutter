import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/navigation/app_navigate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';

class LibrarySubpageHeader extends StatelessWidget {
  const LibrarySubpageHeader({
    super.key,
    required this.title,
    this.centerTitle = false,
    this.showDownloadAction = false,
    this.onDownload,
    this.onSearch,
    this.trailing,
  });

  final String title;
  final bool centerTitle;
  final bool showDownloadAction;
  final VoidCallback? onDownload;
  final VoidCallback? onSearch;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    if (centerTitle) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(
          children: [
            InkWell(
              onTap: Get.back,
              child: const AppIcon(AppAssets.icBackThin, size: 25, color: AppColors.black),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
            ),
            const SizedBox(width: 25),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 10, 0),
      child: Row(
        children: [
          InkWell(
            onTap: Get.back,
            child: const AppIcon(AppAssets.icBackThin, size: 25, color: AppColors.black),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
          if (showDownloadAction)
            InkWell(
              onTap: onDownload ?? () => AppNavigate.toDownloadedSongs(),
              child: const AppIcon(AppAssets.icDownloadThin, size: 25, color: AppColors.black),
            ),
          InkWell(
            onTap: onSearch ?? () => AppNavigate.toSearchSong(),
            child: const Padding(
              padding: EdgeInsets.only(left: 20),
              child: AppIcon(AppAssets.icSearchThin, size: 25, color: AppColors.black),
            ),
          ),
          InkWell(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.only(left: 20),
              child: AppIcon(AppAssets.icMenu, size: 25, color: AppColors.black),
            ),
          ),
        ],
      ),
    );
  }
}
