import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';

/// Matches ServiceMusic `layout_see_all.xml` at end of listen-recent list.
class RecentSeeAllTile extends StatelessWidget {
  const RecentSeeAllTile({super.key, this.onTap});

  final VoidCallback? onTap;

  static const _circleGrey = Color(0xFFDCDCDC);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 5),
            DecoratedBox(
              decoration: const BoxDecoration(
                color: _circleGrey,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Transform.rotate(
                  angle: math.pi,
                  child: const AppIcon(
                    AppAssets.icSeeMore,
                    size: 25,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.see_all,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.2,
                color: AppColors.txtHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
