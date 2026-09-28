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
        // ServiceMusic FragmentMusic: 12×2dp / 18×2.5dp, alpha 0.45 / 1, 3dp gap.
        return GestureDetector(
          onTap: onTap == null ? null : () => onTap!(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(left: i == 0 ? 0 : 3),
            width: active ? 18 : 12,
            height: active ? 2.5 : 2,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(active ? 1 : 0.45),
              borderRadius: BorderRadius.circular(active ? 2 : 1),
            ),
          ),
        );
      }),
    );
  }
}
