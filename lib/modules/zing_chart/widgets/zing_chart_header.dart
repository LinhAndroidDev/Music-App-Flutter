import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';

/// ServiceMusic [ZingChartFragment.initGradientText] + [layout_header] (white actions).
class ZingChartHeader extends StatelessWidget {
  const ZingChartHeader({
    super.key,
    required this.title,
    required this.onSearch,
    required this.onMicrophone,
  });

  final String title;
  final VoidCallback onSearch;
  final VoidCallback onMicrophone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.cyan, Color(0xFFFF00FF), Colors.yellow],
              ).createShader(bounds),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: onMicrophone,
            child: const AppIcon(AppAssets.icMicro, size: 25, color: AppColors.white),
          ),
          const SizedBox(width: 20),
          InkWell(
            onTap: onSearch,
            child: const AppIcon(AppAssets.icSearch, size: 25, color: AppColors.white),
          ),
        ],
      ),
    );
  }
}
