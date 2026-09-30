import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/navigation/app_route.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../data/models/firestore_song.dart';
import '../../../data/models/song.dart';
import '../../../data/services/auth_repository.dart';
import '../../../data/services/firestore_music_repository.dart';
import '../../../data/services/followed_singer_repository.dart';
import '../../library/utils/library_playback.dart';

class SingerDetailController extends BaseController {
  SingerDetailController({
    FirestoreMusicRepository? catalog,
    FollowedSingerRepository? followed,
    AuthRepository? auth,
  })  : _catalog = catalog ?? Get.find<FirestoreMusicRepository>(),
        _followed = followed ?? Get.find<FollowedSingerRepository>(),
        _auth = auth ?? Get.find<AuthRepository>();

  final FirestoreMusicRepository _catalog;
  final FollowedSingerRepository _followed;
  final AuthRepository _auth;

  late final String singerId;
  late final String initialName;
  late final String initialAvatarUrl;

  final isLoading = true.obs;
  final loadError = false.obs;
  final singer = Rxn<FirestoreSinger>();
  final songs = <Song>[].obs;
  final isFollowed = false.obs;

  @override
  void onInit() {
    super.onInit();
    singerId = Get.parameters[AppRouteParam.singerId] ?? '';
    initialName = Get.parameters[AppRouteParam.singerName] ?? '';
    initialAvatarUrl = Get.parameters[AppRouteParam.singerAvatarUrl] ?? '';
    ever(_followed.followedSingers, (_) => _syncFollowed());
    load();
  }

  String displayName(dynamic l10n) {
    final n = singer.value?.name;
    if (n != null && n.isNotEmpty) return n;
    if (initialName.isNotEmpty) return initialName;
    return l10n.singer_info_empty;
  }

  String displayAvatarUrl() {
    final url = singer.value?.avatarUrl;
    if (url != null && url.isNotEmpty) return url;
    return initialAvatarUrl;
  }

  void _syncFollowed() {
    if (singerId.isEmpty) return;
    isFollowed.value = _followed.isFollowed(singerId);
  }

  Future<void> load() async {
    if (singerId.isEmpty) {
      isLoading.value = false;
      loadError.value = true;
      return;
    }
    isLoading.value = true;
    loadError.value = false;
    try {
      final results = await Future.wait([
        _catalog.getSinger(singerId),
        _catalog.getSongsBySinger(singerId),
      ]);
      final s = results[0] as FirestoreSinger?;
      final songDocs = results[1] as List<FirestoreSong>;
      singer.value = s;
      songs.assignAll(songDocs.map(Song.fromFirestoreSong));
      loadError.value = s == null;
      _syncFollowed();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFollow() async {
    final s = singer.value;
    if (s == null) return;
    final l10n = Get.context?.l10n;

    if (isFollowed.value) {
      final result = await _followed.unfollow(singerId);
      _showFollowResult(result, followed: false, l10n: l10n);
      return;
    }

    if (_auth.currentUser.value == null) {
      if (l10n != null) {
        showAppToast(l10n.artist_login_message, category: AppToastCategory.artist);
      }
      return;
    }

    final result = await _followed.follow(s);
    _showFollowResult(result, followed: true, l10n: l10n);
  }

  void _showFollowResult(FollowMutationResult result, {required bool followed, dynamic l10n}) {
    if (l10n == null) return;
    switch (result) {
      case FollowMutationResult.success:
        showAppToast(
          followed ? l10n.artist_followed_toast : l10n.artist_unfollowed_toast,
          category: AppToastCategory.artist,
        );
      case FollowMutationResult.requiresLogin:
        showAppToast(l10n.artist_login_message, category: AppToastCategory.artist);
      case FollowMutationResult.failure:
        showAppToast(l10n.artist_operation_failed, category: AppToastCategory.artist);
    }
  }

  Future<void> playAll() async {
    final l10n = Get.context?.l10n;
    final list = songs.toList();
    if (list.isEmpty) {
      if (l10n != null) {
        showAppToast(l10n.artist_play_empty, category: AppToastCategory.artist);
      }
      return;
    }
    await playVisibleSongList(list, list.first.id);
  }

  Future<void> playSong(Song song) async {
    await playVisibleSongList(songs.toList(), song.id);
  }
}
