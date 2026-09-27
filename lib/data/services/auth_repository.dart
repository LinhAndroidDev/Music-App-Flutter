import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/firebase/firebase_constants.dart';
import '../models/auth_user.dart';
import 'user_repository.dart';

enum GoogleSignInStatus {
  success,
  cancelled,
  configMissing,
  invalidCredential,
  unavailable,
}

class GoogleSignInResult {
  const GoogleSignInResult._(this.status, this.user);

  final GoogleSignInStatus status;
  final AuthUser? user;

  factory GoogleSignInResult.success(AuthUser user) =>
      GoogleSignInResult._(GoogleSignInStatus.success, user);

  factory GoogleSignInResult.cancelled() =>
      const GoogleSignInResult._(GoogleSignInStatus.cancelled, null);

  factory GoogleSignInResult.failure(GoogleSignInStatus status) =>
      GoogleSignInResult._(status, null);
}

class AuthRepository extends GetxService {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              serverClientId: FirebaseConstants.webClientId,
            );

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  final Rxn<AuthUser> currentUser = Rxn<AuthUser>();

  bool get isSignedIn => currentUser.value != null;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _auth.currentUser?.toAuthUser();
    _auth.authStateChanges().listen((user) {
      currentUser.value = user?.toAuthUser();
    });
  }

  AuthUser? get userOrNull => currentUser.value;

  Future<GoogleSignInResult> signInWithGoogle() async {
    if (FirebaseConstants.webClientId.isEmpty) {
      return GoogleSignInResult.failure(GoogleSignInStatus.configMissing);
    }

    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return GoogleSignInResult.cancelled();
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        return GoogleSignInResult.failure(GoogleSignInStatus.invalidCredential);
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final result = await _auth.signInWithCredential(credential);
      final firebaseUser = result.user;
      if (firebaseUser == null) {
        return GoogleSignInResult.failure(GoogleSignInStatus.invalidCredential);
      }

      final user = firebaseUser.toAuthUser();
      currentUser.value = user;

      if (Get.isRegistered<UserRepository>()) {
        await Get.find<UserRepository>().upsertAfterLogin(user);
      }

      return GoogleSignInResult.success(user);
    } on FirebaseAuthException {
      return GoogleSignInResult.failure(GoogleSignInStatus.invalidCredential);
    } catch (_) {
      return GoogleSignInResult.failure(GoogleSignInStatus.unavailable);
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
    currentUser.value = null;
  }

  Future<void> ensureProfileSynced() async {
    final user = currentUser.value;
    if (user == null || !Get.isRegistered<UserRepository>()) return;
    await Get.find<UserRepository>().ensureProfile(user);
  }
}

extension on User {
  AuthUser toAuthUser() => AuthUser(
        uid: uid,
        displayName: displayName ?? '',
        email: email ?? '',
        photoUrl: photoURL,
      );
}
