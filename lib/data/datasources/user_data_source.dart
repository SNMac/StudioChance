import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/data/models/user_model.dart';

part 'user_data_source.g.dart';

abstract interface class UserDataSource {
  Future<UserModel?> getUser(String uid);
  Future<void> createUser(UserModel userModel);

  /// `storeIds`, `fcmTokens를` 수정할 경우 사용 X
  /// - `storeIds` 수정 시: `addStoreId`, `removeStoreId` 메서드 사용
  /// - `fcmTokens` 수정 시: `addFcmToken`, `removeFcmToken` 메서드 사용
  Future<void> updateUser(String uid, Map<String, dynamic> data);
  Future<void> addStoreId(String uid, String storeId);
  Future<void> removeStoreId(String uid, String storeId);
  Future<void> addFcmToken(String uid, String token);
  Future<void> replaceFcmToken(String uid, String oldToken, String newToken);
  Future<void> removeFcmToken(String uid, String token);

  /// `deletedAt` 필드에 현재 시간 추가
  /// - 실제 삭제 X
  Future<void> softDeleteUser(String uid);
}

class UserFirestoreDataSource implements UserDataSource {
  final FirebaseFirestore _firestore;

  UserFirestoreDataSource(this._firestore);

  @override
  Future<UserModel?> getUser(String uid) async {
    final docSnapshot = await _firestore.collection('users').doc(uid).get();
    if (docSnapshot.exists && docSnapshot.data() != null) {
      return UserModel.fromJson(docSnapshot.data()!);
    }
    return null;
  }

  @override
  Future<void> createUser(UserModel userModel) async {
    await _firestore
        .collection('users')
        .doc(userModel.id)
        .set(userModel.toJson());
  }

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  @override
  Future<void> addStoreId(String uid, String storeId) async {
    await _firestore.collection('users').doc(uid).update({
      'storeIds': FieldValue.arrayUnion([storeId]),
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> addFcmToken(String uid, String token) async {
    await _firestore.collection('users').doc(uid).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> replaceFcmToken(
    String uid,
    String oldToken,
    String newToken,
  ) async {
    final docRef = _firestore.collection('users').doc(uid);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'document-not-found',
            message: 'User document not found',
          );
        }

        List<dynamic> tokens = List.from(snapshot.data()?['fcmTokens'] ?? []);

        tokens.remove(oldToken);

        if (!tokens.contains(newToken)) {
          tokens.add(newToken);
        }

        transaction.update(docRef, {
          'fcmTokens': tokens,
          'updatedAt': Timestamp.now(),
        });
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeFcmToken(String uid, String token) async {
    await _firestore.collection('users').doc(uid).update({
      'fcmTokens': FieldValue.arrayRemove([token]),
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> removeStoreId(String uid, String storeId) async {
    await _firestore.collection('users').doc(uid).update({
      'storeIds': FieldValue.arrayRemove([storeId]),
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> softDeleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'deletedAt': Timestamp.now(),
      'fcmTokens': [], // FCM 토큰 초기화
      'updatedAt': Timestamp.now(),
    });
  }
}

@Riverpod(keepAlive: true)
UserDataSource userDataSource(Ref ref) {
  return UserFirestoreDataSource(FirebaseFirestore.instance);
}
