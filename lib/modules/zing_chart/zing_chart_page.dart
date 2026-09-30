import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/assets/app_assets.dart';
import '../../core/l10n/l10n.dart';
import '../../core/navigation/app_navigate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';
import '../discover/widgets/home_chart_song_row.dart';
import '../player/show_song_options.dart';
import '../search/widgets/voice_search_dialog.dart';
import 'zing_chart_controller.dart';
import 'widgets/zing_chart_header.dart';
import 'widgets/zing_chart_line_chart.dart';
import 'widgets/zing_chart_suggested_row.dart';

/// ServiceMusic [ZingChartFragment] / [fragment_zing_chart.xml].
class ZingChartPage extends GetView<ZingChartController> {
  const ZingChartPage({super.key});

  static const _pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.blueDark,
      Color(0xFF35234B),
      AppColors.purpleDark,
    ],
  );

  static const _panelGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.purpleDark1, AppColors.purpleDark2],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      decoration: const BoxDecoration(gradient: _pageGradient),
      child: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value && controller.playlist.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.white),
            );
          }

          return RefreshIndicator(
            color: AppColors.blue1,
            backgroundColor: AppColors.white,
            onRefresh: controller.refreshTopSongs,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ZingChartHeader(
                      title: l10n.nav_zingchart,
                      onSearch: () => AppNavigate.toSearchSong(),
                      onMicrophone: () => VoiceSearchDialog.show(
                        context,
                        onResult: (query) {
                          AppNavigate.toSearchSong(committedQuery: query);
                        },
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Obx(
                          () => Text(
                            controller.chartDateLabel.value,
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: AppIcon(
                            AppAssets.icPlayVideo,
                            size: 20,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Obx(
                    () => ZingChartLineChart(playlist: controller.playlist.toList()),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.only(top: 15),
                    decoration: const BoxDecoration(
                      gradient: _panelGradient,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: Obx(() {
                      final songs = controller.playlist;
                      final suggested = controller.suggestedSong;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (suggested != null)
                            ZingChartSuggestedRow(
                              song: suggested,
                              onTap: () => controller.playSong(suggested.id),
                              onDismiss: controller.dismissSuggested,
                            ),
                          for (var i = 0; i < songs.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: HomeChartSongRow(
                                song: songs[i],
                                index: i,
                                onTap: () => controller.playSong(songs[i].id),
                                onMore: () => showSongOptions(context, songs[i]),
                              ),
                            ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }),
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
