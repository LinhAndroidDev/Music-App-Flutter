import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../core/firebase/firebase_constants.dart';
import '../models/auth_user.dart';
import '../models/firestore_song.dart';
import '../models/followed_singer.dart';
import 'auth_repository.dart';

enum FollowMutationResult {
  success,
  requiresLogin,
  failure,
}

class FollowedSingerRepository extends GetxService {
  FollowedSingerRepository({
    FirebaseFirestore? firestore,
    AuthRepository? authRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository ?? Get.find<AuthRepository>();

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  final followedCount = 0.obs;
  final followedSingers = <FollowedSinger>[].obs;

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
      followedSingers.clear();
      return;
    }
    final uid = user.uid;
    _sub = _collection(uid).snapshots().listen(
      (snap) {
        final list = snap.docs.map(_toSinger).whereType<FollowedSinger>().toList()
          ..sort((a, b) => b.createdAtMillis.compareTo(a.createdAtMillis));
        followedSingers.assignAll(list);
        followedCount.value = list.length;
      },
      onError: (_) {
        followedCount.value = 0;
        followedSingers.clear();
      },
    );
  }

  CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .collection(FirebaseConstants.followedSingersCollection);
  }

  bool isFollowed(String singerId) =>
      followedSingers.any((s) => s.id == singerId);

  Future<FollowMutationResult> follow(FirestoreSinger singer) async {
    final user = _authRepository.currentUser.value;
    if (user == null) return FollowMutationResult.requiresLogin;
    if (singer.id.isEmpty || singer.name.isEmpty) {
      return FollowMutationResult.failure;
    }
    try {
      await _collection(user.uid).doc(singer.id).set({
        'name': singer.name,
        'avatarUrl': singer.avatarUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return FollowMutationResult.success;
    } catch (_) {
      return FollowMutationResult.failure;
    }
  }

  Future<FollowMutationResult> unfollow(String singerId) async {
    final user = _authRepository.currentUser.value;
    if (user == null) return FollowMutationResult.requiresLogin;
    if (singerId.isEmpty) return FollowMutationResult.failure;
    try {
      await _collection(user.uid).doc(singerId).delete();
      return FollowMutationResult.success;
    } catch (_) {
      return FollowMutationResult.failure;
    }
  }

  FollowedSinger? _toSinger(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final name = (doc.data()['name'] as String?)?.trim() ?? '';
    if (doc.id.isEmpty || name.isEmpty) return null;
    final value = doc.data()['createdAt'];
    final createdAt = value is Timestamp ? value : null;
    return FollowedSinger(
      id: doc.id,
      name: name,
      avatarUrl: doc.data()['avatarUrl'] as String? ?? '',
      createdAtMillis: createdAt?.millisecondsSinceEpoch ?? 0,
    );
  }
}
