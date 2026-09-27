import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../core/firebase/firebase_constants.dart';
import '../models/firestore_song.dart';

/// Public music catalog (same queries as ServiceMusic [FirestoreMusicRepository]).
class FirestoreMusicRepository extends GetxService {
  FirestoreMusicRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _songs =>
      _db.collection(FirebaseConstants.songsCollection);

  CollectionReference<Map<String, dynamic>> get _singers =>
      _db.collection(FirebaseConstants.singersCollection);

  CollectionReference<Map<String, dynamic>> get _categories =>
      _db.collection(FirebaseConstants.categoriesCollection);

  CollectionReference<Map<String, dynamic>> get _advertisements =>
      _db.collection(FirebaseConstants.advertisementsCollection);

  List<FirestoreAdvertisement>? _advertisementCache;
  List<FirestoreCategory>? _categoryCache;

  Future<FirestoreSong?> getSong(String id) async {
    if (id.isEmpty) return null;
    final snap = await _fetchDocument(_songs.doc(id));
    if (snap == null || !snap.exists) return null;
    return FirestoreSong.fromDoc(snap);
  }

  Future<List<FirestoreSong>> getLatestSongs({
    int limit = 50,
    bool fromServer = false,
  }) async {
    final snaps = await _fetchQuery(
      fromServer,
      _songs.orderBy('createdAt', descending: true).limit(limit),
    );
    return snaps.map(FirestoreSong.fromDoc).toList();
  }

  Future<List<FirestoreSong>> getTopSongs({
    int limit = 50,
    bool fromServer = false,
  }) async {
    final snaps = await _fetchQuery(
      fromServer,
      _songs.orderBy('views', descending: true).limit(limit),
    );
    return snaps.map(FirestoreSong.fromDoc).toList();
  }

  Future<FirestoreSinger?> getSinger(String id) async {
    if (id.isEmpty) return null;
    final snap = await _fetchDocument(_singers.doc(id));
    if (snap == null || !snap.exists) return null;
    return FirestoreSinger.fromDoc(snap);
  }

  Future<List<FirestoreSinger>> getSingers() async {
    final snaps = await _fetchQuery(false, _singers.orderBy('name'));
    return snaps.map(FirestoreSinger.fromDoc).toList();
  }

  Future<List<FirestoreCategory>> getCategories() async {
    if (_categoryCache != null) return _categoryCache!;
    final snaps = await _fetchQuery(false, _categories);
    final list = snaps.map(FirestoreCategory.fromDoc).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    if (list.isNotEmpty) _categoryCache = list;
    return list;
  }

  Future<List<FirestoreSong>> getSongsByCategory(
    String categoryId, {
    int limit = 50,
  }) async {
    final snaps = await _fetchQuery(
      false,
      _songs.where('categoryId', isEqualTo: categoryId).limit(limit),
    );
    return snaps.map(FirestoreSong.fromDoc).toList();
  }

  Future<List<FirestoreSong>> getSongsBySinger(
    String singerId, {
    int limit = 50,
  }) async {
    final snaps = await _fetchQuery(
      false,
      _songs.where('singerIds', arrayContains: singerId).limit(limit),
    );
    return snaps.map(FirestoreSong.fromDoc).toList();
  }

  Future<List<FirestoreSong>> searchSongsByTitle(
    String term, {
    int limit = 20,
  }) async {
    final keyword = term.trim();
    if (keyword.isEmpty) return [];
    return (await getLatestSongs(limit: 100))
        .where(
          (song) =>
              song.title.toLowerCase().contains(keyword.toLowerCase()) ||
              song.artistText.toLowerCase().contains(keyword.toLowerCase()),
        )
        .take(limit)
        .toList();
  }

  Future<List<FirestoreSinger>> searchSingersByName(
    String term, {
    int limit = 20,
  }) async {
    final keyword = term.trim();
    if (keyword.isEmpty) return [];
    return (await getSingers())
        .where((s) => s.name.toLowerCase().contains(keyword.toLowerCase()))
        .take(limit)
        .toList();
  }

  Future<void> incrementViews(String songId) async {
    if (songId.isEmpty) return;
    try {
      await _songs.doc(songId).update({'views': FieldValue.increment(1)});
    } catch (_) {
      // Best-effort, same as ServiceMusic.
    }
  }

  Future<List<FirestoreAdvertisement>> getAdvertisements({
    bool fromServer = false,
  }) async {
    if (!fromServer && _advertisementCache != null) {
      return _advertisementCache!;
    }
    final snaps = await _fetchQuery(
      fromServer,
      _advertisements.orderBy('createdAt', descending: false),
    );
    final list = snaps.map(FirestoreAdvertisement.fromDoc).toList();
    if (list.isNotEmpty) _advertisementCache = list;
    return list;
  }

  void invalidateAdvertisementCache() => _advertisementCache = null;

  Future<DocumentSnapshot<Map<String, dynamic>>?> _fetchDocument(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    try {
      return await ref.get(const GetOptions(source: Source.serverAndCache));
    } on FirebaseException catch (e) {
      if (_shouldFallbackToCache(e)) {
        return ref.get(const GetOptions(source: Source.cache));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _fetchQuery(
    bool preferServer,
    Query<Map<String, dynamic>> query,
  ) async {
    final primary = preferServer ? Source.server : Source.serverAndCache;
    try {
      final result = await query.get(GetOptions(source: primary));
      return result.docs;
    } on FirebaseException catch (e) {
      if (_shouldFallbackToCache(e)) {
        final cached = await query.get(const GetOptions(source: Source.cache));
        return cached.docs;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  bool _shouldFallbackToCache(FirebaseException error) {
    return error.code == 'unavailable' || error.code == 'failed-precondition';
  }
}
