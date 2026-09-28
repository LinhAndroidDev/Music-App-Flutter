import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../library/widgets/library_song_row.dart';
import '../../player/app_player_shell.dart';
import 'singer_detail_controller.dart';
import 'widgets/singer_description_section.dart';
import 'widgets/singer_follow_play_buttons.dart';

class SingerDetailPage extends GetView<SingerDetailController> {
  const SingerDetailPage({super.key});

  static const _avatarSize = 140.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final s = controller.singer.value;
          final songs = controller.songs;
          final name = s?.name ?? l10n.singer_info_empty;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: AppPlayerShell.scrollListBottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: Get.back,
                      child: const AppIcon(
                        AppAssets.icBackThin,
                        size: 25,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ClipOval(
                    child: SizedBox(
                      width: _avatarSize,
                      height: _avatarSize,
                      child: s != null && s.avatarUrl.isNotEmpty
                          ? CachedNetworkImage(imageUrl: s.avatarUrl, fit: BoxFit.cover)
                          : Container(color: AppColors.greyLight),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.singer_detail_songs_count(songs.length),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: AppColors.txtHint),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => SingerFollowPlayButtons(
                    isFollowed: controller.isFollowed.value,
                    enabled: s != null && !controller.loadError.value,
                    onFollow: controller.toggleFollow,
                    onPlay: controller.playAll,
                  ),
                ),
                if (s != null && s.description.isNotEmpty)
                  SingerDescriptionSection(description: s.description),
                if (songs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text(
                      l10n.singer_detail_songs_empty,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: AppColors.txtHint),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 10, 0),
                    child: Column(
                      children: songs
                          .map(
                            (song) => LibrarySongRow(
                              song: song,
                              onTap: () => controller.playSong(song),
                              onMore: () => Get.snackbar(
                                '',
                                'Tính năng sắp có',
                                snackPosition: SnackPosition.BOTTOM,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
