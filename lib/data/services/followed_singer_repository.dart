import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../core/firebase/firebase_constants.dart';
import '../models/auth_user.dart';
import 'auth_repository.dart';

class FollowedSingerRepository extends GetxService {
  FollowedSingerRepository({
    FirebaseFirestore? firestore,
    AuthRepository? authRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository ?? Get.find<AuthRepository>();

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  final followedCount = 0.obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  @override
  void onInit() {
    super.onInit();
    ever(_authRepository.currentUser, _onUserChanged);
    _onUserChanged(_authRepository.currentUser.value);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  void _onUserChanged(AuthUser? user) {
    _sub?.cancel();
    if (user == null) {
      followedCount.value = 0;
      return;
    }
    final uid = user.uid;
    _sub = _collection(uid).snapshots().listen(
      (snap) => followedCount.value = snap.docs.length,
      onError: (_) => followedCount.value = 0,
    );
  }

  CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .collection(FirebaseConstants.followedSingersCollection);
  }
}
