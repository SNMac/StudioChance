import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/data/data_sources/firestore_data_source_base.dart';
import 'package:studio_chance/data/models/invite_info_model.dart';
import 'package:studio_chance/data/models/store_member_info_model.dart';
import 'package:studio_chance/data/models/store_model.dart';
import 'package:studio_chance/data/models/user_store_info_model.dart';

part 'store_data_source.g.dart';

abstract interface class StoreDataSource {
  /// 점포 생성
  Future<StoreModel> createStore(
    StoreModel store,
    String uid,
    UserStoreInfoModel creatorInfo,
  );

  /// 점포 단일 조회
  Future<StoreModel?> getStore(String storeId);

  /// 점포 정보 수정
  /// - `memberUids`: `data`에 `name`이 포함된 경우, 해당 uid 목록(멤버+대기 멤버)의
  ///   `storeById.{storeId}.name` 캐시를 함께 동기화한다.
  Future<void> updateStore(
    String storeId,
    Map<String, dynamic> data,
    List<String> memberUids,
  );

  /// 점포 삭제 (Soft Delete)
  /// - [memberUids]: 삭제 시점의 멤버+대기 멤버 uid 목록. 각 사용자의
  ///   `storeById.{storeId}` 캐시를 함께 제거하여 데이터 불일치를 방지한다.
  Future<void> softDeleteStore(String storeId, List<String> memberUids);

  /// 멤버 역할 수정
  Future<void> updateMemberRole(String storeId, String uid, String role);

  /// 멤버 삭제 (추방/탈퇴)
  Future<void> removeMember(String storeId, String uid);

  /// 가입 신청 (대기열 추가 + 사용자 점포 정보 저장)
  Future<void> requestJoinWithBatch(
    String storeId,
    String uid,
    StoreMemberInfoModel memberInfo,
    UserStoreInfoModel userStoreInfo,
  );

  /// 가입 승인 (waitingMemberById → memberById 이동)
  /// - 승인된 역할을 users/{uid}.storeById.{storeId}.role에도 동기화한다.
  Future<void> approveMember(
    String storeId,
    String uid,
    StoreMemberInfoModel memberInfo,
  );

  /// 현재 초대 코드 정보 조회 (만료 여부 판단 없이 원본 반환)
  Future<InviteInfoModel?> getInviteInfo(String storeId);

  /// 새 초대 코드를 생성하여 Firestore에 저장
  Future<InviteInfoModel> createInviteCode(String storeId);

  /// 초대 코드로 점포 조회 (만료 검증 없이 단순 조회)
  Future<StoreModel?> getStoreByInviteCode(String inviteCode);

  /// 클라이언트 기기 시각을 신뢰할 수 없는 시각 비교 로직(초대 코드 만료 등)에서
  /// 사용할 Firestore 서버 시각을 조회한다.
  Future<DateTime> getServerTime();
}

class StoreFirestoreDataSource extends FirestoreDataSourceBase
    implements StoreDataSource {
  final FirebaseFirestore _firestore;
  final _rnd = Random();

  StoreFirestoreDataSource(this._firestore);

  @override
  String get errorLogTag => 'Store Firestore Error';

  @override
  bool isDomainException(Object e) => e is StoreException;

  @override
  Exception buildParsingException(String message) =>
      StoreDataParsingException(message: message);

  @override
  Exception mapFirebaseCode(String code, String message) => switch (code) {
    'permission-denied' || 'unauthenticated' =>
      StorePermissionDeniedException(message: message, code: code),
    'not-found' => StoreNotFoundException(message: message, code: code),
    'already-exists' => StoreAlreadyExistsException(message: message, code: code),
    'resource-exhausted' =>
      StoreResourceExhaustedException(message: message, code: code),
    'unavailable' || 'deadline-exceeded' =>
      StoreNetworkException(message: message, code: code),
    'aborted' || 'failed-precondition' =>
      StoreTransactionException(message: message, code: code),
    'cancelled' => StoreCancelledException(message: message, code: code),
    _ => StoreUnknownException(message: message, code: code),
  };

  DocumentReference<Map<String, dynamic>> _storeDocRef(String storeId) {
    return _firestore.collection('stores').doc(storeId);
  }

  @override
  Future<StoreModel> createStore(
    StoreModel store,
    String uid,
    UserStoreInfoModel creatorInfo,
  ) async {
    try {
      final batch = _firestore.batch();
      final docRef = _firestore.collection('stores').doc();

      final json = store.toJson();
      json['createdAt'] = FieldValue.serverTimestamp();
      json['updatedAt'] = FieldValue.serverTimestamp();

      batch.set(docRef, json);

      final userRef = _firestore.collection('users').doc(uid);
      batch.update(userRef, {
        'storeById.${docRef.id}': creatorInfo.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      return store.copyWith(id: docRef.id);
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<StoreModel?> getStore(String storeId) async {
    try {
      final docSnapshot = await _storeDocRef(storeId).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        data['id'] = docSnapshot.id;

        if (data['deletedAt'] != null) return null;

        return StoreModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> updateStore(
    String storeId,
    Map<String, dynamic> data,
    List<String> memberUids,
  ) async {
    try {
      final batch = _firestore.batch();

      final updates = Map<String, dynamic>.from(data);
      updates['updatedAt'] = FieldValue.serverTimestamp();
      batch.update(_storeDocRef(storeId), updates);

      final newName = data['name'] as String?;
      if (newName != null) {
        for (final uid in memberUids) {
          batch.update(_firestore.collection('users').doc(uid), {
            'storeById.$storeId.name': newName,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> updateMemberRole(String storeId, String uid, String role) async {
    try {
      final batch = _firestore.batch();

      final storeRef = _storeDocRef(storeId);
      batch.update(storeRef, {
        'memberById.$uid.role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final userRef = _firestore.collection('users').doc(uid);
      batch.update(userRef, {
        'storeById.$storeId.role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> removeMember(String storeId, String uid) async {
    try {
      final batch = _firestore.batch();

      final storeRef = _storeDocRef(storeId);
      batch.update(storeRef, {
        'memberById.$uid': FieldValue.delete(),
        'waitingMemberById.$uid': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final userRef = _firestore.collection('users').doc(uid);
      batch.update(userRef, {
        'storeById.$storeId': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> requestJoinWithBatch(
    String storeId,
    String uid,
    StoreMemberInfoModel memberInfo,
    UserStoreInfoModel userStoreInfo,
  ) async {
    try {
      final batch = _firestore.batch();
      final storeRef = _storeDocRef(storeId);
      final userRef = _firestore.collection('users').doc(uid);

      batch.update(storeRef, {
        'waitingMemberById.$uid': memberInfo.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.update(userRef, {
        'storeById.$storeId': userStoreInfo.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> approveMember(
    String storeId,
    String uid,
    StoreMemberInfoModel memberInfo,
  ) async {
    try {
      final batch = _firestore.batch();
      final roleJson = memberInfo.toJson()['role'];

      batch.update(_storeDocRef(storeId), {
        'waitingMemberById.$uid': FieldValue.delete(),
        'memberById.$uid': memberInfo.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.update(_firestore.collection('users').doc(uid), {
        'storeById.$storeId.role': roleJson,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> softDeleteStore(String storeId, List<String> memberUids) async {
    try {
      final batch = _firestore.batch();
      final hardDeleteDate = DateTime.now().add(
        const Duration(days: storeSoftDeleteDays),
      );

      batch.update(_storeDocRef(storeId), {
        'deletedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(hardDeleteDate),
        'updatedAt': FieldValue.serverTimestamp(),
        'inviteInfo': null,
      });

      for (final uid in memberUids) {
        batch.update(_firestore.collection('users').doc(uid), {
          'storeById.$storeId': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<InviteInfoModel?> getInviteInfo(String storeId) async {
    try {
      final docSnapshot = await _storeDocRef(storeId).get();

      if (!docSnapshot.exists) {
        throw StoreNotFoundException(message: '점포를 찾을 수 없습니다.');
      }

      final inviteData =
          docSnapshot.data()?['inviteInfo'] as Map<String, dynamic>?;
      if (inviteData == null) return null;

      return InviteInfoModel.fromJson(inviteData);
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<InviteInfoModel> createInviteCode(String storeId) async {
    try {
      final newCode = _generateRandomCode(6);
      final inviteInfoModel = InviteInfoModel(inviteCode: newCode);

      final json = inviteInfoModel.toJson();
      json['createdAt'] = FieldValue.serverTimestamp();

      await _storeDocRef(storeId).update({
        'inviteInfo': json,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return inviteInfoModel;
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<StoreModel?> getStoreByInviteCode(String inviteCode) async {
    try {
      final querySnapshot = await _firestore
          .collection('stores')
          .where('inviteInfo.inviteCode', isEqualTo: inviteCode)
          .where('deletedAt', isNull: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final docSnapshot = querySnapshot.docs.first;
      final data = docSnapshot.data();
      data['id'] = docSnapshot.id;
      return StoreModel.fromJson(data);
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<DateTime> getServerTime() async {
    try {
      final ref = _firestore.collection('system').doc('serverTime');
      await ref.set({'probe': FieldValue.serverTimestamp()});
      final snapshot = await ref.get(const GetOptions(source: Source.server));
      final probe = snapshot.data()?['probe'] as Timestamp?;
      return probe?.toDate() ?? DateTime.now();
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  String _generateRandomCode(int length) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(_rnd.nextInt(chars.length)),
      ),
    );
  }

}

@Riverpod(keepAlive: true)
StoreDataSource storeDataSource(Ref ref) {
  return StoreFirestoreDataSource(FirebaseFirestore.instance);
}
