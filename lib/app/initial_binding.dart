import 'package:get/get.dart';

import '../data/services/auth_repository.dart';
import '../data/services/favourite_song_repository.dart';
import '../data/services/firestore_crud_service.dart';
import '../data/services/firestore_music_repository.dart';
import '../data/services/home_catalog_service.dart';
import '../data/services/followed_singer_repository.dart';
import '../data/services/playlist_repository.dart';
import '../data/services/recent_history_repository.dart';
import '../data/services/user_repository.dart';

/// Global GetX services (Firebase Auth, Firestore).
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<UserRepository>(UserRepository(), permanent: true);
    Get.put<FirestoreCrudService>(FirestoreCrudService(), permanent: true);
    Get.put<FirestoreMusicRepository>(FirestoreMusicRepository(), permanent: true);
    Get.put<HomeCatalogService>(HomeCatalogService(), permanent: true);
    Get.put<AuthRepository>(AuthRepository(), permanent: true);
    Get.put<FavouriteSongRepository>(FavouriteSongRepository(), permanent: true);
    Get.put<FollowedSingerRepository>(FollowedSingerRepository(), permanent: true);
    Get.put<PlaylistRepository>(PlaylistRepository(), permanent: true);
    Get.put<RecentHistoryRepository>(RecentHistoryRepository(), permanent: true);
  }
}
