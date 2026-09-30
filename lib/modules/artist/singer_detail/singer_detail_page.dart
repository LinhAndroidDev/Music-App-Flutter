import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../library/widgets/library_song_row.dart';
import '../../player/app_player_shell.dart';
import '../../player/show_song_options.dart';
import 'singer_detail_controller.dart';
import 'widgets/singer_description_section.dart';
import 'widgets/singer_resizable_header_scroll.dart';

class SingerDetailPage extends GetView<SingerDetailController> {
  const SingerDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final loading = controller.isLoading.value;
          final s = controller.singer.value;
          final songs = controller.songs;
          final hasPreview = controller.initialName.isNotEmpty ||
              controller.initialAvatarUrl.isNotEmpty;

          if (loading && s == null && !hasPreview) {
            return const Center(child: CircularProgressIndicator());
          }

          final name = controller.displayName(l10n);
          final avatarUrl = controller.displayAvatarUrl();

          return SingerResizableHeaderScroll(
            singerId: controller.singerId,
            onBack: Get.back,
            avatarUrl: avatarUrl,
            name: name,
            songCountText: l10n.singer_detail_songs_count(songs.length),
            isFollowed: controller.isFollowed.value,
            onFollow: controller.toggleFollow,
            onPlay: controller.playAll,
            buttonsEnabled: s != null && !controller.loadError.value,
            slivers: [
              if (s != null && s.description.isNotEmpty)
                SliverToBoxAdapter(
                  child: SingerDescriptionSection(description: s.description),
                ),
              if (songs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text(
                      l10n.singer_detail_songs_empty,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: AppColors.txtHint),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 10, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final song = songs[i];
                        return LibrarySongRow(
                          song: song,
                          onTap: () => controller.playSong(song),
                          onMore: () => showSongOptions(context, song),
                        );
                      },
                      childCount: songs.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppPlayerShell.scrollListBottomInset),
              ),
            ],
          );
        }),
      ),
    );
  }
}
