import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';

class SongEmptyState extends StatelessWidget {
  const SongEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.iconAsset = AppAssets.icHeadphone,
  });

  final String title;
  final String subtitle;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      child: Column(
        children: [
          AppIcon(iconAsset, size: 80, color: AppColors.txtHint.withOpacity(0.5)),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.txtHint, height: 1.4),
          ),
        ],
      ),
    );
  }
}
