import 'package:flutter/material.dart';

import '../assets/app_assets.dart';
import '../navigation/app_navigate.dart';
import 'app_toast.dart';
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
            _profileActionWithDot(AppAssets.icSetting),
            const SizedBox(width: 20),
            _profileActionWithDot(AppAssets.icNotificationThin),
            const SizedBox(width: 20),
          ],
          if (showMicrophone) ...[
            InkWell(
              onTap: onMicrophone ??
                  () => showAppToast('Tính năng sắp có'),
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

  /// Matches `layout_header.xml` `viewProfile`: icon + red dot adjacent, 20dp before search.
  static Widget _profileActionWithDot(String iconAsset) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppIcon(iconAsset, size: 25, color: AppColors.black),
        const AppIcon(AppAssets.icCircle, size: 6),
      ],
    );
  }
}
