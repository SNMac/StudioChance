import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/user_exceptions.dart';
import 'package:studio_chance/data/models/user_model.dart';
import 'package:studio_chance/data/models/user_store_info_model.dart';

part 'user_data_source.g.dart';

abstract interface class UserDataSource {
  /// `uid`에 해당하는 사용자 조회
  Future<UserModel?> getUser(String uid);

  /// 사용자 생성
  Future<void> createUser(UserModel userModel);

  /// `storeIds`, `fcmTokens를` 수정할 경우 사용 X
  /// - `storeIds` 수정 시: `addStoreId`, `removeStoreId` 메서드 사용
  /// - `fcmTokens` 수정 시: `addFcmToken`, `replaceFcmToken`, `removeFcmToken` 메서드 사용
  Future<void> updateUser(String uid, Map<String, dynamic> data);

  /// 점포 정보 추가
  Future<void> addStoreInfo(
    String uid,
    String storeId,
    UserStoreInfoModel info,
  );

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

class UserFirestoreDataSource implements UserDataSource {
  final Logger _logger = Logger();
  final FirebaseFirestore _firestore;

  UserFirestoreDataSource(this._firestore);

  @override
  Future<UserModel?> getUser(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
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
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<void> createUser(UserModel userModel) async {
    try {
      final json = userModel.toJson();
      json['createdAt'] = FieldValue.serverTimestamp();
      json['updatedAt'] = FieldValue.serverTimestamp();
      json['lastLoginAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(userModel.id).set(json);
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      final updates = Map<String, dynamic>.from(data);
      updates['updatedAt'] = FieldValue.serverTimestamp();

      if (updates.containsKey('lastLoginAt')) {
        updates['lastLoginAt'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<void> addStoreInfo(
    String uid,
    String storeId,
    UserStoreInfoModel info,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'storeById.$storeId': info.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleFirestoreError(e);
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

      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<void> removeStoreInfo(String uid, String storeId) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'storeById.$storeId': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<void> addFcmToken(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<void> replaceFcmToken(
    String uid,
    String oldToken,
    String newToken,
  ) async {
    try {
      final batch = _firestore.batch();
      final docRef = _firestore.collection('users').doc(uid);

      batch.update(docRef, {
        'fcmTokens': FieldValue.arrayRemove([oldToken]),
      });

      batch.update(docRef, {
        'fcmTokens': FieldValue.arrayUnion([newToken]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<void> removeFcmToken(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<void> softDeleteUser(String uid) async {
    try {
      final hardDeleteDate = DateTime.now().add(const Duration(days: 7));
      await _firestore.collection('users').doc(uid).update({
        'deletedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(hardDeleteDate),
        'fcmTokens': [], // FCM 토큰 초기화
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<void> restoreUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'deletedAt': FieldValue.delete(),
        'expiresAt': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  // ===========================================================================
  // Error Handling
  // ===========================================================================

  Exception _handleFirestoreError(Object e) {
    _logger.e('User Firestore Error', error: e);

    if (e is UserException) return e;

    if (e is TypeError || e is FormatException) {
      return UserDataParsingException(
        message: '데이터 파싱에 실패했습니다.\n${e.toString()}',
      );
    }

    if (e is FirebaseException) {
      final msg = e.message ?? 'Cloud Firestore Error';
      final code = e.code;

      switch (e.code) {
        // 1. 권한/인증
        case 'permission-denied':
        case 'unauthenticated':
          return UserPermissionDeniedException(message: msg, code: code);

        // 2. 데이터 없음
        case 'not-found':
          return UserNotFoundException(message: msg, code: code);

        // 3. 이미 존재함
        case 'already-exists':
          return UserAlreadyExistsException(message: msg, code: code);

        // 4. 할당량/리소스 초과
        case 'resource-exhausted':
          return UserResourceExhaustedException(message: msg, code: code);

        // 5. 네트워크 및 타임아웃
        case 'unavailable':
        case 'deadline-exceeded':
          return UserNetworkException(message: msg, code: code);

        // 6. 트랜잭션 충돌
        case 'aborted':
        case 'failed-precondition':
          return UserTransactionException(message: msg, code: code);

        // 7. 취소됨
        case 'cancelled':
          return UserCancelledException(message: msg, code: code);

        default:
          return UserUnknownException(message: msg, code: code);
      }
    }

    return UserUnknownException(message: e.toString());
  }
}

@Riverpod(keepAlive: true)
UserDataSource userDataSource(Ref ref) {
  return UserFirestoreDataSource(FirebaseFirestore.instance);
}
