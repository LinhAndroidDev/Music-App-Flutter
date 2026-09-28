import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/base/base_controller.dart';
import '../../core/l10n/l10n.dart';
import '../../core/navigation/app_navigate.dart';
import '../../data/models/song.dart';
import '../../core/playback/playback_controller.dart';
import '../../data/playback/song_playback_repository.dart';
import '../../data/services/home_catalog_service.dart';
import 'models/home_advertisement.dart';
import 'models/home_national.dart';
import 'models/home_topic.dart';
import 'utils/song_national_extension.dart';
import 'utils/song_pages.dart';

class DiscoverController extends BaseController {
  DiscoverController({
    HomeCatalogService? catalog,
    PlaybackController? playback,
    SongPlaybackRepository? songQueue,
  })  : _catalog = catalog ?? Get.find<HomeCatalogService>(),
        _playback = playback ?? Get.find<PlaybackController>(),
        _songQueue = songQueue ?? Get.find<SongPlaybackRepository>();

  final HomeCatalogService _catalog;
  final PlaybackController _playback;
  final SongPlaybackRepository _songQueue;

  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final advertisements = <HomeAdvertisement>[].obs;
  final topics = <HomeTopic>[].obs;
  final latestSongs = <Song>[].obs;
  final topSongs = <Song>[].obs;
  final selectedNational = HomeNational.all.obs;

  List<List<Song>> get releasePages {
    final filtered =
        latestSongs.where((s) => s.matchesNational(selectedNational.value)).toList();
    return chunkSongs(filtered);
  }

  List<Song> get chartPreview => topSongs.take(5).toList();

  List<Song> get _filteredLatestSongs =>
      latestSongs.where((s) => s.matchesNational(selectedNational.value)).toList();

  @override
  void onInit() {
    super.onInit();
    _loadInitial();
  }

  @override
  void onReady() {
    super.onReady();
    final ctx = Get.context;
    if (ctx != null) {
      _loadTopicsForContext(ctx);
    }
  }

  Future<void> _loadInitial() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _catalog.ensureLatest(),
        _catalog.ensureTop(),
        _loadAds(),
      ]);
      latestSongs.assignAll(_catalog.latestSongs);
      topSongs.assignAll(_catalog.topSongs);
      _songQueue.syncCachesFromCatalog();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pullToRefresh() async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;
    String? newChart;
    String? top100;
    final ctx = Get.context;
    if (ctx != null && ctx.mounted) {
      final l10n = ctx.l10n;
      newChart = l10n.home_topic_new_chart;
      top100 = l10n.home_topic_top_100;
    }
    try {
      await _catalog.refreshAll();
      final ads = await _catalog.loadAdvertisements(fromServer: true);
      advertisements.assignAll(ads);
      latestSongs.assignAll(_catalog.latestSongs);
      topSongs.assignAll(_catalog.topSongs);
      _songQueue.syncCachesFromCatalog();
      if (newChart != null && top100 != null) {
        await _loadTopics(newChart, top100);
      }
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> _loadTopicsForContext(BuildContext context) async {
    final l10n = context.l10n;
    await _loadTopics(l10n.home_topic_new_chart, l10n.home_topic_top_100);
  }

  Future<void> _loadAds() async {
    final ads = await _catalog.loadAdvertisements();
    advertisements.assignAll(ads);
  }

  Future<void> _loadTopics(String newChart, String top100) async {
    final list = await _catalog.buildTopics(
      newChartTitle: newChart,
      top100Title: top100,
    );
    topics.assignAll(list);
  }

  void selectNational(HomeNational national) {
    selectedNational.value = national;
  }

  void onTopicTap(HomeTopic topic) {
    switch (topic.type) {
      case HomeTopicType.seeAll:
        return;
      case HomeTopicType.newChart:
        AppNavigate.toCategorySongs(
          title: topic.title,
          mode: CategorySongsMode.latest,
        );
      case HomeTopicType.top100:
        AppNavigate.toCategorySongs(
          title: topic.title,
          mode: CategorySongsMode.top,
        );
      case HomeTopicType.category:
        AppNavigate.toCategorySongs(
          title: topic.title,
          mode: CategorySongsMode.category,
          categoryId: topic.categoryId,
        );
    }
  }

  void openZingChartTab() => AppNavigate.toZingChartTab();

  Future<void> playLatestSong(Song song) async {
    final list = _filteredLatestSongs;
    if (list.isEmpty) return;
    await _playSafely(() => _playback.playFromVisibleList(list, song.id));
  }

  Future<void> playChartSong(Song song) async {
    if (topSongs.isEmpty) return;
    await _playSafely(
      () => _playback.playFromVisibleList(topSongs.toList(), song.id),
    );
  }

  Future<void> _playSafely(Future<bool> Function() play) async {
    try {
      AppNavigate.presentPlayerUi();
      final ok = await play();
      if (!ok) {
        AppNavigate.closePlayer();
        _showPlaybackError('Không thể phát bài hát này');
        return;
      }
    } on StateError catch (e) {
      AppNavigate.closePlayer();
      _showPlaybackError(e.message);
    } catch (_) {
      _showPlaybackError('Không thể phát bài hát này');
    }
  }

  void _showPlaybackError(String message) {
    Get.snackbar(
      '',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }
}
