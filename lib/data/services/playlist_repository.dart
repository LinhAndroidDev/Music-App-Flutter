import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../core/firebase/firebase_constants.dart';
import '../models/user_playlist.dart';
import '../models/auth_user.dart';
import 'auth_repository.dart';

enum PlaylistMutationResult {
  success,
  alreadyExists,
  requiresLogin,
  offline,
  failure,
}

class PlaylistRepository extends GetxService {
  PlaylistRepository({
    FirebaseFirestore? firestore,
    AuthRepository? authRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository ?? Get.find<AuthRepository>();

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  final playlists = <UserPlaylist>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  static const _fieldTitle = 'title';
  static const _fieldIsPublic = 'isPublic';
  static const _fieldSongCount = 'songCount';
  static const _fieldCoverUrl = 'coverUrl';
  static const _fieldCreatedAt = 'createdAt';
  static const _fieldUpdatedAt = 'updatedAt';

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
      playlists.clear();
      return;
    }
    final uid = user.uid;
    _sub = _playlistsCollection(uid)
        .orderBy(_fieldCreatedAt, descending: true)
        .snapshots()
        .listen(
      (snap) {
        playlists.assignAll(snap.docs.map(UserPlaylist.fromDoc));
      },
      onError: (_) => playlists.clear(),
    );
  }

  Future<PlaylistMutationResult> createPlaylist({
    required String title,
    bool isPublic = true,
  }) async {
    final user = _authRepository.currentUser.value;
    if (user == null) return PlaylistMutationResult.requiresLogin;

    final name = title.trim();
    if (name.isEmpty) return PlaylistMutationResult.failure;

    try {
      final doc = _playlistsCollection(user.uid).doc();
      await doc.set({
        _fieldTitle: name,
        _fieldIsPublic: isPublic,
        _fieldSongCount: 0,
        _fieldCoverUrl: '',
        _fieldCreatedAt: FieldValue.serverTimestamp(),
        _fieldUpdatedAt: FieldValue.serverTimestamp(),
      });
      return PlaylistMutationResult.success;
    } catch (_) {
      return PlaylistMutationResult.failure;
    }
  }

  CollectionReference<Map<String, dynamic>> _playlistsCollection(String uid) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .collection(FirebaseConstants.playlistsCollection);
  }
}
