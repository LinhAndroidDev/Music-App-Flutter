import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../assets/app_assets.dart';
import '../navigation/app_navigate.dart';
import '../theme/app_colors.dart';
import 'app_icon.dart';

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.showProfileActions = false,
    this.showMicrophone = true,
    this.onSearch,
    this.onMicrophone,
  });

  final String title;
  final bool showProfileActions;
  final bool showMicrophone;
  final VoidCallback? onSearch;
  final VoidCallback? onMicrophone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
          ),
          if (showProfileActions) ...[
            AppIcon(AppAssets.icSetting, size: 25, color: AppColors.black),
            const SizedBox(width: 20),
            AppIcon(AppAssets.icCircle, size: 6, color: AppColors.black),
            const SizedBox(width: 20),
            AppIcon(
              AppAssets.icNotificationThin,
              size: 25,
              color: AppColors.black,
            ),
            const SizedBox(width: 20),
            AppIcon(AppAssets.icCircle, size: 6, color: AppColors.black),
            const SizedBox(width: 20),
          ],
          if (showMicrophone) ...[
            InkWell(
              onTap: onMicrophone ??
                  () => Get.snackbar('', 'Tính năng sắp có',
                      snackPosition: SnackPosition.BOTTOM),
              child: AppIcon(AppAssets.icMicro, size: 25, color: AppColors.black),
            ),
            const SizedBox(width: 20),
          ],
          InkWell(
            onTap: onSearch ?? () => AppNavigate.toSearchSong(),
            child: AppIcon(AppAssets.icSearch, size: 25, color: AppColors.black),
          ),
        ],
      ),
    );
  }
}
