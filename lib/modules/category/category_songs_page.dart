import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/assets/app_assets.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';
import '../library/widgets/library_song_row.dart';
import '../library/widgets/song_empty_state.dart';
import '../player/show_song_options.dart';
import 'category_songs_controller.dart';

/// ServiceMusic [CategorySongsFragment] / [fragment_category_songs.xml].
class CategorySongsPage extends GetView<CategorySongsController> {
  const CategorySongsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Obx(() {
          final songs = controller.songs;
          final loading = controller.isLoading.value;
          final title = controller.title.isNotEmpty
              ? controller.title
              : l10n.home_topics_title;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 10, 0),
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
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.category_songs_count(songs.length),
                      style: const TextStyle(fontSize: 12, color: AppColors.txtHint),
                    ),
                  ],
                ),
              ),
              if (loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (songs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: SongEmptyState(
                    title: l10n.category_songs_empty,
                    subtitle: '',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 10, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = songs[index];
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
            ],
          );
        }),
      ),
    );
  }
}
