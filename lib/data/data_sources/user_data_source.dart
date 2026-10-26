import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/user_exceptions.dart';
import 'package:studio_chance/data/data_sources/firestore_data_source_base.dart';
import 'package:studio_chance/data/models/user_model.dart';

part 'user_data_source.g.dart';

abstract interface class UserDataSource {
  /// `uid`에 해당하는 사용자 조회
  /// - 삭제된 계정(`deletedAt` 존재)은 null. 같은 uid로 다시 로그인하면 새 사용자로 시작한다 (ADR-0005)
  Future<UserModel?> getUser(String uid);

  /// 삭제된 계정까지 포함한 사용자 조회 (예약 작성자처럼 다른 사람 이름 표시용)
  /// - 삭제된 계정은 닉네임만 담긴 [UserModel.deleted]로 반환한다
  Future<UserModel?> getUserIncludingDeleted(String uid);

  /// 사용자 생성
  Future<void> createUser(UserModel userModel, {String? fcmToken});

  /// 일반 필드 업데이트 (`storeById` 수정 불가, FCM 토큰은 `users/{uid}/private/fcm` 서브문서 별도 관리)
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

  /// FCM 토큰 추가
  Future<void> addFcmToken(String uid, String token);

  /// FCM 토큰 교체
  Future<void> replaceFcmToken(String uid, String oldToken, String newToken);

  /// FCM 토큰 삭제
  Future<void> removeFcmToken(String uid, String token);

  /// 계정 삭제: 사용자 문서를 `{nickname, deletedAt}`만 남도록 덮어쓰고 FCM 토큰 문서를 지운다
  /// - 문서를 지우지 않는 이유: 남은 예약의 작성자와 멤버 변동 알림 문구가 닉네임을 읽는다 (ADR-0005)
  Future<void> markAccountDeleted(String uid, {required String nickname});
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
    'permission-denied' || 'unauthenticated' => UserPermissionDeniedException(
      message: message,
      code: code,
    ),
    'not-found' => UserNotFoundException(message: message, code: code),
    'already-exists' => UserAlreadyExistsException(
      message: message,
      code: code,
    ),
    'resource-exhausted' => UserResourceExhaustedException(
      message: message,
      code: code,
    ),
    'unavailable' ||
    'deadline-exceeded' => UserNetworkException(message: message, code: code),
    'aborted' || 'failed-precondition' => UserTransactionException(
      message: message,
      code: code,
    ),
    'cancelled' => UserCancelledException(message: message, code: code),
    _ => UserUnknownException(message: message, code: code),
  };

  DocumentReference<Map<String, dynamic>> _userDocRef(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  /// FCM 토큰 전용 문서. users/{uid} 본문은 다른 사용자도 읽을 수 있으므로
  /// 토큰은 본인만 접근 가능한 이 경로에 둔다 (firestore.rules 참고).
  ///
  /// 토큰을 추가·교체·제거하는 경로(`recordLogin`, `addFcmToken`, `replaceFcmToken`,
  /// `removeFcmToken`)는 반드시 `set(..., merge: true)`를 쓴다 — `update`는 문서가 없으면
  /// 실패하는데 첫 로그인 기기에는 이 문서가 없다. 문서를 처음 만드는 `createUser`는
  /// `SetOptions` 없이 쓰는 것이 맞다.
  DocumentReference<Map<String, dynamic>> _fcmDocRef(String uid) {
    return _userDocRef(uid).collection('private').doc('fcm');
  }

  @override
  Future<UserModel?> getUser(String uid) async {
    final user = await getUserIncludingDeleted(uid);
    return user == null || user.isDeleted ? null : user;
  }

  @override
  Future<UserModel?> getUserIncludingDeleted(String uid) async {
    try {
      final docSnapshot = await _userDocRef(uid).get();
      final data = docSnapshot.data();
      if (!docSnapshot.exists || data == null) return null;

      if (data['deletedAt'] != null) {
        return UserModel.deleted(
          id: docSnapshot.id,
          nickname: data['nickname'] as String?,
        );
      }

      data['id'] = docSnapshot.id;
      return UserModel.fromJson(data);
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> createUser(UserModel userModel, {String? fcmToken}) async {
    try {
      final json = userModel.toJson();
      json['createdAt'] = FieldValue.serverTimestamp();
      json['updatedAt'] = FieldValue.serverTimestamp();
      json['lastLoginAt'] = FieldValue.serverTimestamp();

      final batch = _firestore.batch();
      batch.set(_userDocRef(userModel.id), json);
      if (fcmToken != null) {
        batch.set(_fcmDocRef(userModel.id), {
          'tokens': [fcmToken],
        });
      }
      await batch.commit();
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
      final batch = _firestore.batch();
      batch.update(_userDocRef(uid), {
        'authProviders': authProviders,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (fcmToken != null) {
        // update는 문서가 없으면 실패한다. 첫 로그인 기기에서도 동작해야 하므로
        // 반드시 merge set을 쓴다.
        batch.set(_fcmDocRef(uid), {
          'tokens': FieldValue.arrayUnion([fcmToken]),
        }, SetOptions(merge: true));
      }
      await batch.commit();
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
  Future<void> addFcmToken(String uid, String token) async {
    try {
      await _fcmDocRef(uid).set({
        'tokens': FieldValue.arrayUnion([token]),
      }, SetOptions(merge: true));
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
      final docRef = _fcmDocRef(uid);

      // arrayRemove + arrayUnion을 동일 필드에 적용하므로 Transaction으로 원자성 보장
      await _firestore.runTransaction((tx) async {
        final doc = await tx.get(docRef);
        final tokens = List<String>.from(doc.data()?['tokens'] ?? []);
        tokens.remove(oldToken);
        if (!tokens.contains(newToken)) tokens.add(newToken);

        tx.set(docRef, {'tokens': tokens}, SetOptions(merge: true));
      });
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> removeFcmToken(String uid, String token) async {
    try {
      await _fcmDocRef(uid).set({
        'tokens': FieldValue.arrayRemove([token]),
      }, SetOptions(merge: true));
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> markAccountDeleted(
    String uid, {
    required String nickname,
  }) async {
    try {
      final batch = _firestore.batch();
      // SetOptions 없이 덮어써서 이메일·이름·로그인 수단·storeById를 모두 지운다
      batch.set(_userDocRef(uid), {
        'nickname': nickname,
        'deletedAt': FieldValue.serverTimestamp(),
      });
      batch.delete(_fcmDocRef(uid));
      await batch.commit();
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
}

@Riverpod(keepAlive: true)
UserDataSource userDataSource(Ref ref) {
  return UserFirestoreDataSource(FirebaseFirestore.instance);
}
