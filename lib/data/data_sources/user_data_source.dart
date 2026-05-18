import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/user_exceptions.dart';
import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/data/data_sources/firestore_data_source_base.dart';
import 'package:studio_chance/data/models/user_model.dart';

part 'user_data_source.g.dart';

abstract interface class UserDataSource {
  /// `uid`에 해당하는 사용자 조회
  Future<UserModel?> getUser(String uid);

  /// 사용자 조회 및 복구 통합 메서드
  /// - 탈퇴 상태(`deletedAt` 존재)라면 `restoreUser`를 호출하여 복구 후 반환
  Future<UserModel?> fetchUserWithRestoration(String uid);

  /// 사용자 생성
  Future<void> createUser(UserModel userModel);

  /// 일반 필드 업데이트 (`storeById`, `fcmTokens` 수정 불가)
  Future<void> updateUser(String uid, Map<String, dynamic> data);

  /// 로그인 시점 정보 갱신 (`lastLoginAt`, `authProviders`, FCM 토큰)
  Future<void> recordLogin(
    String uid, {
    required List<String> authProviders,
    String? fcmToken,
  });

  /// 점포 정보 업데이트
  Future<void> updateStoreInfo(
    String uid,
    String storeId,
    Map<String, dynamic> data,
  );

  /// 점포 정보 삭제
  Future<void> removeStoreInfo(String uid, String storeId);

  /// FCM 토큰 추가
  Future<void> addFcmToken(String uid, String token);

  /// FCM 토큰 교체
  Future<void> replaceFcmToken(String uid, String oldToken, String newToken);

  /// FCM 토큰 삭제
  Future<void> removeFcmToken(String uid, String token);

  /// 사용자 soft delete (`deletedAt`)
  /// - hard delete는 7일 뒤 (`expiresAt` = `deletedAt` + 7일)
  Future<void> softDeleteUser(String uid);

  /// 계정 복구 (탈퇴 취소)
  /// - `deletedAt`, `expiresAt` 필드를 삭제하여 계정을 활성화 상태로 되돌립니다.
  Future<void> restoreUser(String uid);
}

class UserFirestoreDataSource extends FirestoreDataSourceBase
    implements UserDataSource {
  final FirebaseFirestore _firestore;

  UserFirestoreDataSource(this._firestore);

  @override
  String get errorLogTag => 'User Firestore Error';

  @override
  bool isDomainException(Object e) => e is UserException;

  @override
  Exception buildParsingException(String message) =>
      UserDataParsingException(message: message);

  @override
  Exception mapFirebaseCode(String code, String message) => switch (code) {
    'permission-denied' || 'unauthenticated' =>
      UserPermissionDeniedException(message: message, code: code),
    'not-found' => UserNotFoundException(message: message, code: code),
    'already-exists' => UserAlreadyExistsException(message: message, code: code),
    'resource-exhausted' =>
      UserResourceExhaustedException(message: message, code: code),
    'unavailable' || 'deadline-exceeded' =>
      UserNetworkException(message: message, code: code),
    'aborted' || 'failed-precondition' =>
      UserTransactionException(message: message, code: code),
    'cancelled' => UserCancelledException(message: message, code: code),
    _ => UserUnknownException(message: message, code: code),
  };

  DocumentReference<Map<String, dynamic>> _userDocRef(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  @override
  Future<UserModel?> getUser(String uid) async {
    try {
      final docSnapshot = await _userDocRef(uid).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        data['id'] = docSnapshot.id;

        if (data['deletedAt'] != null) {
          return null;
        }

        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<UserModel?> fetchUserWithRestoration(String uid) async {
    try {
      final docSnapshot = await _userDocRef(uid).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        data['id'] = docSnapshot.id;

        if (data['deletedAt'] != null) {
          logger.i('탈퇴 계정 감지: $uid');

          await restoreUser(uid);

          data.remove('deletedAt');
          data.remove('expiresAt');
        }

        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> createUser(UserModel userModel) async {
    try {
      final json = userModel.toJson();
      json['createdAt'] = FieldValue.serverTimestamp();
      json['updatedAt'] = FieldValue.serverTimestamp();
      json['lastLoginAt'] = FieldValue.serverTimestamp();

      await _userDocRef(userModel.id).set(json);
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      final updates = Map<String, dynamic>.from(data);
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _userDocRef(uid).update(updates);
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> recordLogin(
    String uid, {
    required List<String> authProviders,
    String? fcmToken,
  }) async {
    try {
      final updates = <String, dynamic>{
        'authProviders': authProviders,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (fcmToken != null) {
        updates['fcmTokens'] = FieldValue.arrayUnion([fcmToken]);
      }
      await _userDocRef(uid).update(updates);
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> updateStoreInfo(
    String uid,
    String storeId,
    Map<String, dynamic> data,
  ) async {
    try {
      final Map<String, dynamic> updates = {};
      data.forEach((key, value) {
        updates['storeById.$storeId.$key'] = value;
      });

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _userDocRef(uid).update(updates);
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> removeStoreInfo(String uid, String storeId) async {
    try {
      await _userDocRef(uid).update({
        'storeById.$storeId': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> addFcmToken(String uid, String token) async {
    try {
      await _userDocRef(uid).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> replaceFcmToken(
    String uid,
    String oldToken,
    String newToken,
  ) async {
    try {
      final docRef = _userDocRef(uid);

      // arrayRemove + arrayUnion을 동일 필드에 적용하므로 Transaction으로 원자성 보장
      await _firestore.runTransaction((tx) async {
        final doc = await tx.get(docRef);
        final tokens = List<String>.from(doc.data()?['fcmTokens'] ?? []);
        tokens.remove(oldToken);
        if (!tokens.contains(newToken)) tokens.add(newToken);

        tx.update(docRef, {
          'fcmTokens': tokens,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> removeFcmToken(String uid, String token) async {
    try {
      await _userDocRef(uid).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> softDeleteUser(String uid) async {
    try {
      // expiresAt은 클라이언트 시각 기준으로 계산됩니다.
      // deletedAt(서버 타임스탬프)과 미세한 차이가 있을 수 있으나,
      // 7일 만료 기준에서 실질적인 문제가 없으므로 허용합니다.
      final hardDeleteDate = DateTime.now().add(const Duration(days: userSoftDeleteDays));
      await _userDocRef(uid).update({
        'deletedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(hardDeleteDate),
        'fcmTokens': [], // FCM 토큰 초기화
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> restoreUser(String uid) async {
    try {
      await _userDocRef(uid).update({
        'deletedAt': FieldValue.delete(),
        'expiresAt': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      logger.i('계정 복구 완료: $uid');
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

}

@Riverpod(keepAlive: true)
UserDataSource userDataSource(Ref ref) {
  return UserFirestoreDataSource(FirebaseFirestore.instance);
}
