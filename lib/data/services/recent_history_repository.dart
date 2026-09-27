import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../core/firebase/firebase_constants.dart';
import '../models/song.dart';
import '../models/auth_user.dart';
import 'auth_repository.dart';

/// Firestore recent songs when logged in; empty when guest (no local Room yet).
class RecentHistoryRepository extends GetxService {
  RecentHistoryRepository({
    FirebaseFirestore? firestore,
    AuthRepository? authRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository ?? Get.find<AuthRepository>();

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  final recentSongs = <Song>[].obs;
  final isLoading = true.obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  static const _fieldLastPlayedAt = 'lastPlayedAt';
  static const _defaultLimit = 100;

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
      recentSongs.clear();
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    final uid = user.uid;
    _sub = _recentCollection(uid)
        .orderBy(_fieldLastPlayedAt, descending: true)
        .limit(_defaultLimit)
        .snapshots()
        .listen(
      (snap) {
        recentSongs.assignAll(
          snap.docs.map(Song.fromFirestoreDocument).where((s) => s.id.isNotEmpty),
        );
        isLoading.value = false;
      },
      onError: (_) {
        recentSongs.clear();
        isLoading.value = false;
      },
    );
  }

  List<Song> previewSongs({int limit = 5}) {
    if (recentSongs.length <= limit) return recentSongs.toList();
    return recentSongs.take(limit).toList();
  }

  bool get showSeeAll => recentSongs.length > 5;

  CollectionReference<Map<String, dynamic>> _recentCollection(String uid) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .collection(FirebaseConstants.recentSongsCollection);
  }
}
