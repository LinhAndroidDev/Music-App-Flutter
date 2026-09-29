import 'package:get/get.dart';

import '../../core/base/base_controller.dart';
import '../../core/l10n/l10n.dart';
import '../../core/widgets/app_toast.dart';
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
        showAppToast(l10n.auth_config_missing, category: AppToastCategory.auth);
      case GoogleSignInStatus.invalidCredential:
        showAppToast(l10n.auth_invalid_credential, category: AppToastCategory.auth);
      case GoogleSignInStatus.unavailable:
        showAppToast(l10n.auth_google_unavailable, category: AppToastCategory.auth);
    }
  }
}
