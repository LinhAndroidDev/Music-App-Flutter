import 'package:get/get.dart';

import '../../core/base/base_controller.dart';
import '../../core/navigation/app_route.dart';
import '../../data/models/firestore_song.dart';
import '../../data/models/song.dart';
import '../../data/services/firestore_music_repository.dart';
import '../discover/models/home_topic.dart';
import '../library/utils/library_playback.dart';

class CategorySongsController extends BaseController {
  CategorySongsController({FirestoreMusicRepository? catalog})
      : _catalog = catalog ?? Get.find<FirestoreMusicRepository>();

  final FirestoreMusicRepository _catalog;

  final isLoading = true.obs;
  final songs = <Song>[].obs;

  late final String title;
  late final String mode;
  late final String categoryId;

  @override
  void onInit() {
    super.onInit();
    title = Get.parameters[AppRouteParam.title] ?? '';
    mode = Get.parameters[AppRouteParam.mode] ?? CategorySongsMode.category;
    categoryId = Get.parameters[AppRouteParam.categoryId] ?? '';
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final docs = await _fetchSongDocuments();
      songs.assignAll(docs.map(Song.fromFirestoreSong));
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<FirestoreSong>> _fetchSongDocuments() async {
    switch (mode) {
      case CategorySongsMode.latest:
        return _catalog.getLatestSongs(limit: 100);
      case CategorySongsMode.top:
        return _catalog.getTopSongs(limit: 100);
      case CategorySongsMode.category:
        if (categoryId.isEmpty) return [];
        return _catalog.getSongsByCategory(categoryId, limit: 100);
      default:
        return [];
    }
  }

  Future<void> playSong(Song song) async {
    final list = songs.toList();
    if (list.isEmpty) return;
    await playVisibleSongList(list, song.id);
  }
}
