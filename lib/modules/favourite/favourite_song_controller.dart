import 'package:get/get.dart';

import '../../core/base/base_controller.dart';
import '../../core/l10n/l10n.dart';
import '../../core/widgets/app_toast.dart';
import '../../data/models/song.dart';
import '../../data/models/song_arrangement.dart';
import '../../data/playback/playback_preferences.dart';
import '../../data/services/favourite_song_repository.dart';
import '../../data/services/favourite_song_sorter.dart';
import '../library/utils/library_playback.dart';

class FavouriteSongController extends BaseController {
  FavouriteSongController({
    FavouriteSongRepository? favourites,
    PlaybackPreferences? preferences,
  })  : _favourites = favourites ?? Get.find<FavouriteSongRepository>(),
        _preferences = preferences ?? Get.find<PlaybackPreferences>();

  final FavouriteSongRepository _favourites;
  final PlaybackPreferences _preferences;

  final arrangement = SongArrangement.newest.obs;
  final sortedSongs = <Song>[].obs;

  @override
  void onInit() {
    super.onInit();
    arrangement.value = _preferences.getSongArrangementSync();
    ever(_favourites.favouriteRecords, (_) => _applySort());
    ever(arrangement, (_) => _applySort());
    _applySort();
  }

  void _applySort() {
    sortedSongs.assignAll(
      sortFavouriteRecords(_favourites.favouriteRecords.toList(), arrangement.value),
    );
  }

  Future<void> changeArrangement(SongArrangement value) async {
    arrangement.value = value;
    await _preferences.saveSongArrangement(value);
  }

  String arrangementLabel(dynamic l10n) {
    return switch (arrangement.value) {
      SongArrangement.newest => l10n.arrange_newest,
      SongArrangement.oldest => l10n.arrange_oldest,
      SongArrangement.bySongName => l10n.arrange_by_song_name,
      SongArrangement.byArtistName => l10n.arrange_by_artist_name,
    };
  }

  Future<void> playSong(Song song) async {
    await playVisibleSongList(sortedSongs.toList(), song.id);
  }

  Future<void> playShuffle() async {
    final list = sortedSongs.toList();
    if (list.isEmpty) return;
    list.shuffle();
    await playVisibleSongList(list, list.first.id);
  }

  Future<void> removeFavourite(Song song) async {
    final l10n = Get.context?.l10n;
    final result = await _favourites.removeFavourite(song.id);
    if (result == FavouriteMutationResult.success && l10n != null) {
      showAppToast(l10n.toast_removed_favourite, category: AppToastCategory.favourite);
    } else if (result == FavouriteMutationResult.requiresLogin && l10n != null) {
      showAppToast(l10n.favourite_login_required, category: AppToastCategory.favourite);
    } else if (l10n != null) {
      showAppToast(l10n.favourite_operation_failed, category: AppToastCategory.favourite);
    }
  }
}
