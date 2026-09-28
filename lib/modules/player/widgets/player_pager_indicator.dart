import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PlayerPagerIndicator extends StatelessWidget {
  const PlayerPagerIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
    this.onTap,
  });

  final int pageCount;
  final int currentPage;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (i) {
        final active = i == currentPage;
        return GestureDetector(
          onTap: onTap == null ? null : () => onTap!(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 18 : 12,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(active ? 1 : 0.45),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
