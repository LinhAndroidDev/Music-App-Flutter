import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../core/firebase/firebase_constants.dart';
import '../models/auth_user.dart';
import '../models/song.dart';
import 'auth_repository.dart';

class FavouriteSongRepository extends GetxService {
  FavouriteSongRepository({
    FirebaseFirestore? firestore,
    AuthRepository? authRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository ?? Get.find<AuthRepository>();

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  final favouriteCount = 0.obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _favSub;

  @override
  void onInit() {
    super.onInit();
    ever(_authRepository.currentUser, _onUserChanged);
    _onUserChanged(_authRepository.currentUser.value);
  }

  @override
  void onClose() {
    _favSub?.cancel();
    super.onClose();
  }

  void _onUserChanged(AuthUser? user) {
    _favSub?.cancel();
    if (user == null) {
      favouriteCount.value = 0;
      return;
    }
    final uid = user.uid;
    _favSub = _favouriteCollection(uid).snapshots().listen(
      (snap) => favouriteCount.value = snap.docs.length,
      onError: (_) => favouriteCount.value = 0,
    );
  }

  CollectionReference<Map<String, dynamic>> _favouriteCollection(String uid) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .collection(FirebaseConstants.favouriteSongsCollection);
  }

  Stream<bool> watchIsFavourite(String songId) {
    if (songId.isEmpty) return Stream.value(false);
    final user = _authRepository.currentUser.value;
    if (user == null) return Stream.value(false);
    return _favouriteCollection(user.uid).doc(songId).snapshots().map((s) => s.exists);
  }

  Future<bool> toggleFavourite(Song song) async {
    if (song.id.isEmpty) return false;
    final user = _authRepository.currentUser.value;
    if (user == null) return false;
    final ref = _favouriteCollection(user.uid).doc(song.id);
    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
      return false;
    }
    await ref.set({
      'songId': song.id,
      'title': song.title,
      'nameSinger': song.nameSinger,
      'thumbnailUrl': song.thumbnailUrl,
      'audioUrl': song.audioUrl,
      'lyricUrl': song.lyricUrl,
      'durationSec': song.durationSec,
      'categoryId': song.categoryId,
      'categoryName': song.categoryName,
      'views': song.views,
      'addedAt': FieldValue.serverTimestamp(),
    });
    return true;
  }
}
