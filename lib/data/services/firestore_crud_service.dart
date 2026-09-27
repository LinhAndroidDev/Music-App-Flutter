import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

/// Generic Firestore create / read / update / delete helpers.
class FirestoreCrudService extends GetxService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> collection(String name) {
    return _db.collection(name);
  }

  DocumentReference<Map<String, dynamic>> document(String path) {
    return _db.doc(path);
  }

  Future<Map<String, dynamic>?> getData(String path) async {
    final snap = await document(path).get();
    if (!snap.exists) return null;
    return snap.data();
  }

  Future<void> set(
    String path,
    Map<String, dynamic> data, {
    bool merge = false,
  }) {
    return document(path).set(data, SetOptions(merge: merge));
  }

  Future<void> update(String path, Map<String, dynamic> data) {
    return document(path).update(data);
  }

  Future<void> delete(String path) {
    return document(path).delete();
  }

  /// Creates a document with auto id in [collectionPath].
  Future<String> add(String collectionPath, Map<String, dynamic> data) async {
    final ref = await collection(collectionPath).add(data);
    return ref.id;
  }

  /// Creates or overwrites document at [collectionPath]/[documentId].
  Future<void> setWithId(
    String collectionPath,
    String documentId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) {
    return collection(collectionPath).doc(documentId).set(data, SetOptions(merge: merge));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDocument(String path) {
    return document(path).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollection(
    String collectionPath, {
    Query<Map<String, dynamic>> Function(CollectionReference<Map<String, dynamic>> ref)?
        query,
  }) {
    final ref = collection(collectionPath);
    final q = query != null ? query(ref) : ref;
    return q.snapshots();
  }
}
