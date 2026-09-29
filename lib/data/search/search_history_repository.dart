import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/auth_user.dart';
import '../services/auth_repository.dart';
import 'search_catalog.dart';
import 'search_query.dart';
import 'vietnamese_fold.dart';

String searchQueryDocumentId(String normalizedQuery) {
  var id = normalizedQuery.replaceAll('/', '_').trim();
  if (id.length > 150) {
    id = id.substring(0, 150);
  }
  return id.isEmpty ? 'query' : id;
}

class SearchHistoryRepository extends GetxService {
  SearchHistoryRepository({
    FirebaseFirestore? firestore,
    AuthRepository? authRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository ?? Get.find<AuthRepository>();

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  final recentQueries = <SearchQuery>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  static const _usersCollection = 'users';
  static const _searchQueriesCollection = 'searchQueries';
  static const _fieldQuery = 'query';
  static const _fieldNormalizedQuery = 'normalizedQuery';
  static const _fieldLastSearchedAt = 'lastSearchedAt';

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
      recentQueries.clear();
      return;
    }
    _sub = _queriesCollection(user.uid)
        .orderBy(_fieldLastSearchedAt, descending: true)
        .limit(SearchCatalog.historyLimit)
        .snapshots()
        .listen(
      (snap) {
        recentQueries.assignAll(
          snap.docs.map(_toSearchQuery).whereType<SearchQuery>(),
        );
      },
      onError: (_) => recentQueries.clear(),
    );
  }

  Future<void> recordQuery(String raw) async {
    final query = raw.trim();
    final normalizedQuery = VietnameseFold.fold(query);
    final uid = _authRepository.currentUser.value?.uid;
    if (uid == null || query.isEmpty || normalizedQuery.isEmpty) return;

    await _queriesCollection(uid)
        .doc(searchQueryDocumentId(normalizedQuery))
        .set(
      {
        _fieldQuery: query,
        _fieldNormalizedQuery: normalizedQuery,
        _fieldLastSearchedAt: FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> deleteQuery(String normalizedQuery) async {
    final uid = _authRepository.currentUser.value?.uid;
    if (uid == null || normalizedQuery.isEmpty) return;
    await _queriesCollection(uid)
        .doc(searchQueryDocumentId(normalizedQuery))
        .delete();
  }

  Future<void> clearAll() async {
    final uid = _authRepository.currentUser.value?.uid;
    if (uid == null) return;
    final snap = await _queriesCollection(uid).get();
    if (snap.docs.isEmpty) return;
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  CollectionReference<Map<String, dynamic>> _queriesCollection(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_searchQueriesCollection);
  }

  SearchQuery? _toSearchQuery(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return null;
    var query = (data[_fieldQuery] as String?) ?? '';
    if (query.isEmpty) {
      query = (data[_fieldNormalizedQuery] as String?) ?? '';
    }
    var normalizedQuery = (data[_fieldNormalizedQuery] as String?) ?? '';
    if (normalizedQuery.isEmpty) {
      normalizedQuery = VietnameseFold.fold(query);
    }
    if (query.isEmpty || normalizedQuery.isEmpty) return null;
    final ts = data[_fieldLastSearchedAt];
    final millis = ts is Timestamp ? ts.millisecondsSinceEpoch : 0;
    return SearchQuery(
      query: query,
      normalizedQuery: normalizedQuery,
      lastSearchedAt: millis,
    );
  }
}
