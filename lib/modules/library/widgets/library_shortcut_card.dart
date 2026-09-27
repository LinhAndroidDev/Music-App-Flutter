import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/widgets/app_icon.dart';

class LibraryShortcutCard extends StatelessWidget {
  const LibraryShortcutCard({
    super.key,
    required this.iconAsset,
    required this.iconColor,
    required this.title,
    required this.count,
    this.leadingMargin = false,
    this.onTap,
  });

  final String iconAsset;
  final Color iconColor;
  final String title;
  final int count;
  final bool leadingMargin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: leadingMargin ? 15 : 0, right: 15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 140,
          decoration: AppDecorations.libraryShortcutCard(),
          padding: const EdgeInsets.fromLTRB(10, 13, 10, 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIcon(iconAsset, size: 30, color: iconColor),
              const SizedBox(height: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 5),
              Opacity(
                opacity: count == 0 ? 0 : 1,
                child: Text(
                  count == 0 ? '' : '$count',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.txtHint,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
