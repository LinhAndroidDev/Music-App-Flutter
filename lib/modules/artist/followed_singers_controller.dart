import 'package:get/get.dart';

import '../../core/base/base_controller.dart';
import '../../core/l10n/l10n.dart';
import '../../core/navigation/app_navigate.dart';
import '../../core/widgets/app_toast.dart';
import '../../data/models/followed_singer.dart';
import '../../data/services/auth_repository.dart';
import '../../data/services/followed_singer_repository.dart';

class FollowedSingersController extends BaseController {
  FollowedSingersController({
    FollowedSingerRepository? followed,
    AuthRepository? auth,
  })  : _followed = followed ?? Get.find<FollowedSingerRepository>(),
        _auth = auth ?? Get.find<AuthRepository>();

  final FollowedSingerRepository _followed;
  final AuthRepository _auth;

  RxList<FollowedSinger> get singers => _followed.followedSingers;

  void openSingerDetail(FollowedSinger singer) {
    AppNavigate.toSingerDetail(
      singerId: singer.id,
      singerName: singer.name,
      singerAvatarUrl: singer.avatarUrl,
    );
  }

  Future<void> openAddArtist() async {
    if (_auth.currentUser.value == null) {
      final l10n = Get.context?.l10n;
      if (l10n != null) {
        showAppToast(l10n.artist_login_message, category: AppToastCategory.artist);
      }
      return;
    }
    await AppNavigate.toAddArtist();
  }
}
