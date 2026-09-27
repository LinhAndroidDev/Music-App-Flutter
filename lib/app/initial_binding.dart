import 'package:get/get.dart';

import '../data/services/auth_repository.dart';
import '../data/services/firestore_crud_service.dart';
import '../data/services/firestore_music_repository.dart';
import '../data/services/user_repository.dart';

/// Global GetX services (Firebase Auth, Firestore).
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<UserRepository>(UserRepository(), permanent: true);
    Get.put<FirestoreCrudService>(FirestoreCrudService(), permanent: true);
    Get.put<FirestoreMusicRepository>(FirestoreMusicRepository(), permanent: true);
    Get.put<AuthRepository>(AuthRepository(), permanent: true);
  }
}
