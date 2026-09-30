import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../playlist/playlist_shared_element.dart';
import '../../playlist/widgets/playlist_hero_widgets.dart';
import '../../../data/models/user_playlist.dart';

class PlaylistListTile extends StatelessWidget {
  const PlaylistListTile({
    super.key,
    required this.playlist,
    required this.metaText,
    this.onTap,
  });

  final UserPlaylist playlist;
  final String metaText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Row(
          children: [
            PlaylistHeroCover(
              tag: PlaylistSharedElement.coverTag(playlist.id),
              coverUrl: playlist.coverUrl,
              size: 56,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PlaylistHeroTitle(
                    tag: PlaylistSharedElement.titleTag(playlist.id),
                    title: playlist.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    metaText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.txtHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
