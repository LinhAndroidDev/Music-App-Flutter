import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/l10n/l10n.dart';
import '../../data/models/song.dart';
import '../../core/navigation/app_navigate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/screen_header.dart';
import '../library/widgets/recent_see_all_tile.dart';
import 'discover_controller.dart';
import 'models/home_national.dart';
import 'models/home_topic.dart';
import 'widgets/home_ad_banner_carousel.dart';
import 'widgets/home_national_chip.dart';
import 'widgets/home_release_song_row.dart';
import 'widgets/home_section_title.dart';
import 'widgets/home_topic_tile.dart';
import 'widgets/home_zing_chart_card.dart';

class DiscoverPage extends GetView<DiscoverController> {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value && controller.latestSongs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            color: AppColors.blue,
            backgroundColor: AppColors.white,
            onRefresh: controller.pullToRefresh,
            child: CustomScrollView(
              clipBehavior: Clip.none,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ScreenHeader(
                      title: l10n.nav_discover,
                      onSearch: () => AppNavigate.toSearchSong(),
                      onMicrophone: () {},
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Obx(
                          () => HomeAdBannerCarousel(
                            ads: controller.advertisements.toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: HomeSectionTitle(title: l10n.home_topics_title),
                ),
                SliverToBoxAdapter(
                  child: Obx(() => _TopicsRow(
                        topics: controller.topics.toList(),
                        onTopicTap: controller.onTopicTap,
                      )),
                ),
                SliverToBoxAdapter(
                  child: HomeSectionTitle(title: l10n.home_new_releases),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, top: 10),
                    child: Obx(
                      () => Row(
                        children: [
                          HomeNationalChip(
                            label: l10n.tab_all,
                            selected: controller.selectedNational.value == HomeNational.all,
                            onTap: () => controller.selectNational(HomeNational.all),
                          ),
                          HomeNationalChip(
                            label: l10n.tab_vietnam,
                            selected:
                                controller.selectedNational.value == HomeNational.vietnam,
                            onTap: () => controller.selectNational(HomeNational.vietnam),
                          ),
                          HomeNationalChip(
                            label: l10n.tab_international,
                            selected: controller.selectedNational.value ==
                                HomeNational.international,
                            onTap: () =>
                                controller.selectNational(HomeNational.international),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Obx(
                    () => _NewReleasePager(
                      key: ValueKey(
                        '${controller.selectedNational.value}_${controller.releasePages.length}',
                      ),
                      pages: controller.releasePages,
                      onSongTap: controller.playLatestSong,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Obx(
                    () => HomeZingChartCard(
                      songs: controller.chartPreview,
                      chartDateLabel: l10n.preview_home_chart_date,
                      onSeeAll: controller.openZingChartTab,
                      onSongTap: controller.playChartSong,
                      onSongMore: controller.playChartSong,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _NewReleasePager extends StatefulWidget {
  const _NewReleasePager({
    super.key,
    required this.pages,
    required this.onSongTap,
  });

  final List<List<Song>> pages;
  final void Function(Song song) onSongTap;

  @override
  State<_NewReleasePager> createState() => _NewReleasePagerState();
}

class _NewReleasePagerState extends State<_NewReleasePager> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pages.isEmpty) {
      return const SizedBox(height: 250);
    }
    return SizedBox(
      height: 250,
      child: PageView.builder(
        controller: _pageController,
        padEnds: false,
        itemCount: widget.pages.length,
        itemBuilder: (_, pageIndex) {
          final pageSongs = widget.pages[pageIndex];
          return Padding(
            padding: const EdgeInsets.only(left: 15, right: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: pageSongs
                  .map(
                    (s) => HomeReleaseSongRow(
                      song: s,
                      onTap: () => widget.onSongTap(s),
                      onMore: () => widget.onSongTap(s),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}

class _TopicsRow extends StatelessWidget {
  const _TopicsRow({
    required this.topics,
    required this.onTopicTap,
  });

  final List<HomeTopic> topics;
  final void Function(HomeTopic topic) onTopicTap;

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) {
      return const SizedBox(height: 80);
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 15, top: 15),
        itemCount: topics.length,
        itemBuilder: (_, i) {
          final topic = topics[i];
          if (topic.type == HomeTopicType.seeAll) {
            return RecentSeeAllTile(onTap: () {});
          }
          return HomeTopicTile(
            topic: topic,
            onTap: () => onTopicTap(topic),
          );
        },
      ),
    );
  }
}
