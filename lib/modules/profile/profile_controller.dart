import 'package:get/get.dart';

import '../../core/base/base_controller.dart';
import '../../core/l10n/l10n.dart';
import '../../data/services/auth_repository.dart';

class ProfileController extends BaseController {
  final AuthRepository _auth = Get.find<AuthRepository>();

  final isLoading = false.obs;

  AuthRepository get auth => _auth;

  Future<void> onAuthButtonPressed() async {
    if (isLoading.value) return;
    if (_auth.isSignedIn) {
      await _auth.signOut();
      return;
    }

    isLoading.value = true;
    final l10n = Get.context?.l10n;
    final result = await _auth.signInWithGoogle();
    isLoading.value = false;

    if (l10n == null) return;

    switch (result.status) {
      case GoogleSignInStatus.success:
        break;
      case GoogleSignInStatus.cancelled:
        break;
      case GoogleSignInStatus.configMissing:
        Get.snackbar('', l10n.auth_config_missing);
      case GoogleSignInStatus.invalidCredential:
        Get.snackbar('', l10n.auth_invalid_credential);
      case GoogleSignInStatus.unavailable:
        Get.snackbar('', l10n.auth_google_unavailable);
    }
  }
}
