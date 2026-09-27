import 'package:get/get.dart';

import '../../core/assets/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/discover/models/home_advertisement.dart';
import '../../modules/discover/models/home_topic.dart';
import '../models/firestore_song.dart';
import '../models/song.dart';
import 'firestore_music_repository.dart';

class HomeCatalogService extends GetxService {
  HomeCatalogService({FirestoreMusicRepository? musicRepository})
      : _music = musicRepository ?? Get.find<FirestoreMusicRepository>();

  final FirestoreMusicRepository _music;

  List<Song> _latestSongs = [];
  List<Song> _topSongs = [];

  List<Song> get latestSongs => List.unmodifiable(_latestSongs);
  List<Song> get topSongs => List.unmodifiable(_topSongs);

  Future<void> ensureLatest() async {
    if (_latestSongs.isNotEmpty) return;
    await _loadLatest(force: false);
  }

  Future<void> ensureTop() async {
    if (_topSongs.isNotEmpty) return;
    await _loadTop(force: false);
  }

  Future<List<HomeAdvertisement>> loadAdvertisements({bool fromServer = false}) async {
    final ads = await _music.getAdvertisements(fromServer: fromServer);
    return ads.map(HomeAdvertisement.fromFirestore).toList();
  }

  Future<void> refreshAll() async {
    _music.invalidateAdvertisementCache();
    await Future.wait([
      _loadLatest(force: true),
      _loadTop(force: true),
    ]);
  }

  Future<List<HomeTopic>> buildTopics({
    required String newChartTitle,
    required String top100Title,
  }) async {
    final categories = await _music.getCategories();
    const categoryColors = [
      AppColors.bgOrange,
      AppColors.bgPink,
      AppColors.bgGreen1,
      AppColors.bgGreen2,
    ];

    return [
      HomeTopic(
        type: HomeTopicType.newChart,
        title: newChartTitle,
        iconAsset: AppAssets.icMusic,
        backgroundColor: AppColors.bgBlue,
      ),
      HomeTopic(
        type: HomeTopicType.top100,
        title: top100Title,
        iconAsset: AppAssets.icStar,
        backgroundColor: AppColors.bgPurple,
      ),
      ...categories.asMap().entries.map(
            (e) => HomeTopic(
              type: HomeTopicType.category,
              title: e.value.name,
              backgroundColor: categoryColors[e.key % categoryColors.length],
              categoryId: e.value.id,
            ),
          ),
      const HomeTopic(
        type: HomeTopicType.seeAll,
        title: '',
      ),
    ];
  }

  Future<void> _loadLatest({required bool force}) async {
    if (!force && _latestSongs.isNotEmpty) return;
    final list = await _music.getLatestSongs(fromServer: force);
    _latestSongs = list.map(_toSong).toList();
  }

  Future<void> _loadTop({required bool force}) async {
    if (!force && _topSongs.isNotEmpty) return;
    final list = await _music.getTopSongs(fromServer: force);
    _topSongs = list.map(_toSong).toList();
  }

  Song _toSong(FirestoreSong fs) => Song.fromFirestoreSong(fs);
}
