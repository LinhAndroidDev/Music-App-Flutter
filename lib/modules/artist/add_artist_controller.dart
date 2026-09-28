import 'package:get/get.dart';

import '../../core/base/base_controller.dart';
import '../../core/l10n/l10n.dart';
import '../../data/models/firestore_song.dart';
import '../../data/services/firestore_music_repository.dart';
import '../../data/services/followed_singer_repository.dart';

class AddArtistController extends BaseController {
  AddArtistController({
    FirestoreMusicRepository? catalog,
    FollowedSingerRepository? followed,
  })  : _catalog = catalog ?? Get.find<FirestoreMusicRepository>(),
        _followed = followed ?? Get.find<FollowedSingerRepository>();

  final FirestoreMusicRepository _catalog;
  final FollowedSingerRepository _followed;

  final isLoading = true.obs;
  final isSaving = false.obs;
  final query = ''.obs;
  final allSingers = <FirestoreSinger>[].obs;
  final selectedIds = <String>{}.obs;

  List<FirestoreSinger> get visibleSingers {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return allSingers;
    return allSingers.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final singers = await _catalog.getSingers();
      allSingers.assignAll(singers);
    } finally {
      isLoading.value = false;
    }
  }

  void setQuery(String value) => query.value = value;

  void toggleSelection(String singerId) {
    if (selectedIds.contains(singerId)) {
      selectedIds.remove(singerId);
    } else {
      selectedIds.add(singerId);
    }
  }

  Future<void> complete() async {
    final l10n = Get.context?.l10n;
    if (selectedIds.isEmpty) {
      if (l10n != null) {
        Get.snackbar('', l10n.artist_add_select_required, snackPosition: SnackPosition.BOTTOM);
      }
      return;
    }
    isSaving.value = true;
    try {
      for (final id in selectedIds) {
        final singer = allSingers.firstWhereOrNull((s) => s.id == id);
        if (singer == null) continue;
        if (_followed.isFollowed(id)) continue;
        final result = await _followed.follow(singer);
        if (result == FollowMutationResult.requiresLogin) {
          if (l10n != null) {
            Get.snackbar('', l10n.artist_login_message, snackPosition: SnackPosition.BOTTOM);
          }
          return;
        }
      }
      // Pop before snackbar — Get.back() after Get.snackbar only closes the snackbar overlay.
      Get.back();
      if (l10n != null) {
        Future.microtask(
          () => Get.snackbar(
            '',
            l10n.artist_followed_toast,
            snackPosition: SnackPosition.BOTTOM,
          ),
        );
      }
    } finally {
      isSaving.value = false;
    }
  }
}
