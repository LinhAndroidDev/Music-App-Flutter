import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../core/firebase/firebase_constants.dart';
import '../models/auth_user.dart';
import '../models/song.dart';
import '../models/user_playlist.dart';
import 'auth_repository.dart';

enum PlaylistMutationResult {
  success,
  alreadyExists,
  requiresLogin,
  offline,
  failure,
}

class PlaylistWriteResult {
  const PlaylistWriteResult(this.status, {this.playlistId});

  final PlaylistMutationResult status;
  final String? playlistId;
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

  static const _songsCollection = 'songs';
  static const _fieldTitle = 'title';
  static const _fieldIsPublic = 'isPublic';
  static const _fieldSongCount = 'songCount';
  static const _fieldCoverUrl = 'coverUrl';
  static const _fieldCreatedAt = 'createdAt';
  static const _fieldUpdatedAt = 'updatedAt';
  static const _fieldOrder = 'order';
  static const _fieldAddedAt = 'addedAt';

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

  Stream<UserPlaylist?> watchPlaylist(String playlistId) {
    final uid = _authRepository.currentUser.value?.uid;
    if (uid == null || playlistId.isEmpty) {
      return Stream.value(null);
    }
    return _playlistsCollection(uid).doc(playlistId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return UserPlaylist.fromDoc(snap);
    });
  }

  Stream<List<Song>> watchSongs(String playlistId) {
    final uid = _authRepository.currentUser.value?.uid;
    if (uid == null || playlistId.isEmpty) {
      return Stream.value(const []);
    }
    return _playlistsCollection(uid)
        .doc(playlistId)
        .collection(_songsCollection)
        .snapshots()
        .map(_songsFromSnapshot);
  }

  List<Song> _songsFromSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final records = snapshot.docs.map(_songRecordFromDoc).whereType<_PlaylistSongRecord>().toList()
      ..sort((a, b) {
        final o = a.order.compareTo(b.order);
        if (o != 0) return o;
        return a.addedAt.compareTo(b.addedAt);
      });
    return records.map((r) => r.song).toList();
  }

  Future<PlaylistWriteResult> createPlaylist({
    required String title,
    bool isPublic = true,
  }) async {
    final user = _authRepository.currentUser.value;
    final pre = _writePrecondition(user?.uid);
    if (pre != null) return PlaylistWriteResult(pre);

    final name = title.trim();
    if (name.isEmpty) return const PlaylistWriteResult(PlaylistMutationResult.failure);

    try {
      final doc = _playlistsCollection(user!.uid).doc();
      await doc.set({
        _fieldTitle: name,
        _fieldIsPublic: isPublic,
        _fieldSongCount: 0,
        _fieldCoverUrl: '',
        _fieldCreatedAt: FieldValue.serverTimestamp(),
        _fieldUpdatedAt: FieldValue.serverTimestamp(),
      });
      return PlaylistWriteResult(PlaylistMutationResult.success, playlistId: doc.id);
    } on FirebaseException catch (e) {
      return PlaylistWriteResult(_mapFirebaseError(e));
    } catch (_) {
      return const PlaylistWriteResult(PlaylistMutationResult.failure);
    }
  }

  Future<PlaylistMutationResult> addSong(
    String playlistId,
    Song song, {
    String currentCoverUrl = '',
  }) async {
    final user = _authRepository.currentUser.value;
    final pre = _writePrecondition(user?.uid);
    if (pre != null) return pre;
    if (playlistId.isEmpty || song.id.isEmpty) {
      return PlaylistMutationResult.failure;
    }

    try {
      final playlistRef = _playlistsCollection(user!.uid).doc(playlistId);
      final songsRef = playlistRef.collection(_songsCollection);
      final existing = await songsRef.get();
      if (existing.docs.any((d) => d.id == song.id)) {
        return PlaylistMutationResult.alreadyExists;
      }
      final nextOrder = existing.docs
              .map((d) => d.data()[_fieldOrder] as num?)
              .whereType<num>()
              .fold<int>(-1, (max, o) => o.toInt() > max ? o.toInt() : max) +
          1;

      final updates = <String, dynamic>{
        _fieldSongCount: FieldValue.increment(1),
        _fieldUpdatedAt: FieldValue.serverTimestamp(),
      };
      if (currentCoverUrl.isEmpty && song.thumbnailUrl.isNotEmpty) {
        updates[_fieldCoverUrl] = song.thumbnailUrl;
      }

      final batch = _firestore.batch();
      batch.set(songsRef.doc(song.id), _songToMap(song, nextOrder), SetOptions(merge: true));
      batch.update(playlistRef, updates);
      await batch.commit();
      return PlaylistMutationResult.success;
    } on FirebaseException catch (e) {
      return _mapFirebaseError(e);
    } catch (_) {
      return PlaylistMutationResult.failure;
    }
  }

  Future<PlaylistMutationResult> removeSong(String playlistId, String songId) async {
    final user = _authRepository.currentUser.value;
    final pre = _writePrecondition(user?.uid);
    if (pre != null) return pre;
    if (playlistId.isEmpty || songId.isEmpty) return PlaylistMutationResult.failure;

    try {
      final playlistRef = _playlistsCollection(user!.uid).doc(playlistId);
      final songsRef = playlistRef.collection(_songsCollection);
      final existing = await songsRef.get();
      final remaining = existing.docs.where((d) => d.id != songId).toList();
      if (remaining.length == existing.docs.length) {
        return PlaylistMutationResult.failure;
      }

      final records = remaining.map(_songRecordFromDoc).whereType<_PlaylistSongRecord>().toList()
        ..sort((a, b) {
          final o = a.order.compareTo(b.order);
          if (o != 0) return o;
          return a.addedAt.compareTo(b.addedAt);
        });
      final nextCover = records.isEmpty ? '' : records.first.song.thumbnailUrl;

      final batch = _firestore.batch();
      batch.delete(songsRef.doc(songId));
      batch.update(playlistRef, {
        _fieldSongCount: FieldValue.increment(-1),
        _fieldCoverUrl: nextCover,
        _fieldUpdatedAt: FieldValue.serverTimestamp(),
      });
      await batch.commit();
      return PlaylistMutationResult.success;
    } on FirebaseException catch (e) {
      return _mapFirebaseError(e);
    } catch (_) {
      return PlaylistMutationResult.failure;
    }
  }

  Future<PlaylistMutationResult> updatePlaylist({
    required String playlistId,
    required String title,
    required bool isPublic,
  }) async {
    final user = _authRepository.currentUser.value;
    final pre = _writePrecondition(user?.uid);
    if (pre != null) return pre;
    if (playlistId.isEmpty) return PlaylistMutationResult.failure;

    final name = title.trim();
    if (name.isEmpty) return PlaylistMutationResult.failure;

    try {
      await _playlistsCollection(user!.uid).doc(playlistId).update({
        _fieldTitle: name,
        _fieldIsPublic: isPublic,
        _fieldUpdatedAt: FieldValue.serverTimestamp(),
      });
      return PlaylistMutationResult.success;
    } on FirebaseException catch (e) {
      return _mapFirebaseError(e);
    } catch (_) {
      return PlaylistMutationResult.failure;
    }
  }

  Future<PlaylistMutationResult> reorderSongs({
    required String playlistId,
    required List<String> songIds,
    String firstCoverUrl = '',
  }) async {
    final user = _authRepository.currentUser.value;
    final pre = _writePrecondition(user?.uid);
    if (pre != null) return pre;
    if (playlistId.isEmpty) return PlaylistMutationResult.failure;

    try {
      final playlistRef = _playlistsCollection(user!.uid).doc(playlistId);
      final songsRef = playlistRef.collection(_songsCollection);
      final batch = _firestore.batch();
      for (var i = 0; i < songIds.length; i++) {
        final id = songIds[i];
        if (id.isEmpty) continue;
        batch.update(songsRef.doc(id), {_fieldOrder: i});
      }
      final playlistUpdates = <String, dynamic>{
        _fieldUpdatedAt: FieldValue.serverTimestamp(),
      };
      if (firstCoverUrl.isNotEmpty) {
        playlistUpdates[_fieldCoverUrl] = firstCoverUrl;
      }
      batch.update(playlistRef, playlistUpdates);
      await batch.commit();
      return PlaylistMutationResult.success;
    } on FirebaseException catch (e) {
      return _mapFirebaseError(e);
    } catch (_) {
      return PlaylistMutationResult.failure;
    }
  }

  Future<PlaylistMutationResult> deletePlaylist(String playlistId) async {
    final user = _authRepository.currentUser.value;
    final pre = _writePrecondition(user?.uid);
    if (pre != null) return pre;
    if (playlistId.isEmpty) return PlaylistMutationResult.failure;

    try {
      final playlistRef = _playlistsCollection(user!.uid).doc(playlistId);
      final songs = await playlistRef.collection(_songsCollection).get();
      for (var i = 0; i < songs.docs.length; i += 400) {
        final chunk = songs.docs.skip(i).take(400);
        final batch = _firestore.batch();
        for (final doc in chunk) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
      await playlistRef.delete();
      return PlaylistMutationResult.success;
    } on FirebaseException catch (e) {
      return _mapFirebaseError(e);
    } catch (_) {
      return PlaylistMutationResult.failure;
    }
  }

  Map<String, dynamic> _songToMap(Song song, int order) {
    return {
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
      _fieldOrder: order,
      _fieldAddedAt: FieldValue.serverTimestamp(),
    };
  }

  _PlaylistSongRecord? _songRecordFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final song = Song.fromFirestoreDocument(doc);
    if (song.id.isEmpty) return null;
    final data = doc.data();
    final order = (data[_fieldOrder] as num?)?.toInt() ?? 1 << 30;
    final addedAt = (data[_fieldAddedAt] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
    return _PlaylistSongRecord(song: song, order: order, addedAt: addedAt);
  }

  PlaylistMutationResult? _writePrecondition(String? uid) {
    if (uid == null || uid.isEmpty) return PlaylistMutationResult.requiresLogin;
    return null;
  }

  PlaylistMutationResult _mapFirebaseError(FirebaseException e) {
    if (e.code == 'unavailable' || e.code == 'network-request-failed') {
      return PlaylistMutationResult.offline;
    }
    return PlaylistMutationResult.failure;
  }

  CollectionReference<Map<String, dynamic>> _playlistsCollection(String uid) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .collection(FirebaseConstants.playlistsCollection);
  }
}

class _PlaylistSongRecord {
  const _PlaylistSongRecord({
    required this.song,
    required this.order,
    required this.addedAt,
  });

  final Song song;
  final int order;
  final int addedAt;
}
