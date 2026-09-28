import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';

class SingerFollowPlayButtons extends StatelessWidget {
  const SingerFollowPlayButtons({
    super.key,
    required this.isFollowed,
    required this.onFollow,
    required this.onPlay,
    this.enabled = true,
  });

  final bool isFollowed;
  final VoidCallback onFollow;
  final VoidCallback onPlay;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: isFollowed ? AppColors.purple1 : AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: isFollowed
                    ? BorderSide.none
                    : const BorderSide(color: AppColors.grey1, width: 1),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: enabled ? onFollow : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Text(
                      isFollowed ? l10n.artist_following : l10n.artist_follow,
                      style: TextStyle(
                        fontSize: 15,
                        color: isFollowed ? AppColors.white : AppColors.textBlack,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Material(
              color: AppColors.purple1,
              borderRadius: BorderRadius.circular(25),
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: enabled ? onPlay : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Text(
                      l10n.artist_play,
                      style: const TextStyle(fontSize: 15, color: AppColors.white),
                    ),
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
