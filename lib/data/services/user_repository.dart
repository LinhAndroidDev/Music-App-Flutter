import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../core/firebase/firebase_constants.dart';
import '../models/auth_user.dart';

class UserRepository extends GetxService {
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> ensureProfile(AuthUser user) => _upsertProfile(user, recordLogin: false);

  Future<void> upsertAfterLogin(AuthUser user) => _upsertProfile(user, recordLogin: true);

  Future<void> _upsertProfile(AuthUser user, {required bool recordLogin}) async {
    if (user.uid.isEmpty) {
      throw ArgumentError('UID người dùng không hợp lệ');
    }

    final doc = _firestore.collection(FirebaseConstants.usersCollection).doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(doc);
      final profile = <String, dynamic>{
        'uid': user.uid,
        'displayName': user.displayName,
        'email': user.email,
        'photoUrl': user.photoUrl,
        'provider': FirebaseConstants.googleProvider,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (recordLogin) {
        profile['lastLoginAt'] = FieldValue.serverTimestamp();
      }
      if (!snapshot.exists) {
        profile['createdAt'] = FieldValue.serverTimestamp();
      }

      transaction.set(doc, profile, SetOptions(merge: true));
    });
  }

  /// Path helper: `users/{uid}/...`
  DocumentReference<Map<String, dynamic>> userDoc(String uid) {
    return _firestore.collection(FirebaseConstants.usersCollection).doc(uid);
  }
}
