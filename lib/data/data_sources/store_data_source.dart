import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/constants/data_constants.dart';
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
  Future<void> updateStore(String storeId, Map<String, dynamic> data);

  /// 점포 삭제 (Soft Delete)
  Future<void> softDeleteStore(String storeId);

  /// 멤버 역할 수정
  Future<void> updateMemberRole(String storeId, String uid, String role);

  /// 멤버 삭제 (추방/탈퇴)
  Future<void> removeMember(String storeId, String uid);

  /// 가입 신청
  Future<void> addWaitingMember(
    String storeId,
    String uid,
    StoreMemberInfoModel memberInfo,
  );

  /// 가입 승인
  Future<void> approveMemberWithBatch(
    String storeId,
    String uid,
    StoreMemberInfoModel memberInfo,
    UserStoreInfoModel userStoreInfo,
  );

  /// 초대 코드 발급
  /// - [forceRegenerate]: true면 무조건 새로 생성, false면 유효한 기존 코드 반환
  /// - 유효기간: 생성일시로부터 15분
  Future<InviteInfoModel> createInviteCode(
    String storeId, {
    bool forceRegenerate = false,
  });

  /// 초대 코드로 점포 조회
  Future<StoreModel?> getStoreByInviteCode(String inviteCode);
}

class StoreFirestoreDataSource implements StoreDataSource {
  final Logger _logger = Logger();
  final FirebaseFirestore _firestore;

  StoreFirestoreDataSource(this._firestore);

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
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<StoreModel?> getStore(String storeId) async {
    try {
      final docSnapshot = await _firestore
          .collection('stores')
          .doc(storeId)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        data['id'] = docSnapshot.id;

        if (data['deletedAt'] != null) return null;

        return StoreModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<void> updateStore(String storeId, Map<String, dynamic> data) async {
    try {
      final updates = Map<String, dynamic>.from(data);
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('stores').doc(storeId).update(updates);
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<void> updateMemberRole(String storeId, String uid, String role) async {
    try {
      final batch = _firestore.batch();

      final storeRef = _firestore.collection('stores').doc(storeId);
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
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<void> removeMember(String storeId, String uid) async {
    try {
      final batch = _firestore.batch();

      final storeRef = _firestore.collection('stores').doc(storeId);
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
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<void> addWaitingMember(
    String storeId,
    String uid,
    StoreMemberInfoModel memberInfo,
  ) async {
    try {
      await _firestore.collection('stores').doc(storeId).update({
        'waitingMemberById.$uid': memberInfo.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<void> approveMemberWithBatch(
    String storeId,
    String uid,
    StoreMemberInfoModel memberInfo,
    UserStoreInfoModel userStoreInfo,
  ) async {
    try {
      final batch = _firestore.batch();
      final storeRef = _firestore.collection('stores').doc(storeId);
      final userRef = _firestore.collection('users').doc(uid);

      batch.update(storeRef, {
        'waitingMemberById.$uid': FieldValue.delete(),
        'memberById.$uid': memberInfo.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.update(userRef, {
        'storeById.$storeId': userStoreInfo.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<void> softDeleteStore(String storeId) async {
    try {
      final hardDeleteDate = DateTime.now().add(
        const Duration(days: storeSoftDeleteDays),
      );
      await _firestore.collection('stores').doc(storeId).update({
        'deletedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(hardDeleteDate),
        'updatedAt': FieldValue.serverTimestamp(),
        'inviteInfo': null,
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<InviteInfoModel> createInviteCode(
    String storeId, {
    bool forceRegenerate = false,
  }) async {
    try {
      if (!forceRegenerate) {
        final docSnapshot = await _firestore
            .collection('stores')
            .doc(storeId)
            .get();

        if (!docSnapshot.exists) {
          throw StoreNotFoundException(message: '점포를 찾을 수 없습니다.');
        }

        final data = docSnapshot.data() ?? {};
        final inviteData = data['inviteInfo'] as Map<String, dynamic>?;

        if (inviteData != null && inviteData['createdAt'] != null) {
          final createdAt = (inviteData['createdAt'] as Timestamp).toDate();
          final expiresAt = createdAt.add(
            const Duration(minutes: storeInviteCodeAvailableMin),
          );

          if (DateTime.now().isBefore(expiresAt)) {
            return InviteInfoModel.fromJson(inviteData);
          }
        }
      }

      final newCode = _generateRandomCode(6);
      final inviteInfoModel = InviteInfoModel(inviteCode: newCode);

      final json = inviteInfoModel.toJson();
      json['createdAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('stores').doc(storeId).update({
        'inviteInfo': json,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return inviteInfoModel;
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<StoreModel?> getStoreByInviteCode(String inviteCode) async {
    try {
      final querySnapshot = await _firestore
          .collection('stores')
          .where('inviteInfo.inviteCode', isEqualTo: inviteCode)
          .where('deletedAt', isNull: true) // 삭제된 점포 제외
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final docSnapshot = querySnapshot.docs.first;
      final data = docSnapshot.data();
      final inviteData = data['inviteInfo'] as Map<String, dynamic>?;

      if (inviteData != null && inviteData['createdAt'] != null) {
        final createdAt = (inviteData['createdAt'] as Timestamp).toDate();
        final expiresAt = createdAt.add(
          const Duration(minutes: storeInviteCodeAvailableMin),
        );

        if (DateTime.now().isAfter(expiresAt)) {
          throw StoreNotFoundException(message: '유효하지 않은 초대 코드입니다.');
        }
      } else {
        throw StoreNotFoundException(message: '유효하지 않은 초대 코드입니다.');
      }

      data['id'] = docSnapshot.id;
      return StoreModel.fromJson(data);
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  // ===========================================================================
  // Helper Methods
  // ===========================================================================

  String _generateRandomCode(int length) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
      ),
    );
  }

  // ===========================================================================
  // Error Handling
  // ===========================================================================

  Exception _handleFirestoreError(Object e) {
    _logger.e('Store Firestore Error', error: e);

    if (e is StoreException) return e;

    if (e is TypeError || e is FormatException) {
      return StoreDataParsingException(
        message: '데이터 파싱에 실패했습니다.\n${e.toString()}',
      );
    }

    if (e is FirebaseException) {
      final msg = e.message ?? 'Cloud Firestore Error';
      final code = e.code;

      switch (code) {
        case 'permission-denied':
        case 'unauthenticated':
          return StorePermissionDeniedException(message: msg, code: code);
        case 'not-found':
          return StoreNotFoundException(message: msg, code: code);
        case 'already-exists':
          return StoreAlreadyExistsException(message: msg, code: code);
        case 'resource-exhausted':
          return StoreResourceExhaustedException(message: msg, code: code);
        case 'unavailable':
        case 'deadline-exceeded':
          return StoreNetworkException(message: msg, code: code);
        case 'aborted':
        case 'failed-precondition':
          return StoreTransactionException(message: msg, code: code);
        case 'cancelled':
          return StoreCancelledException(message: msg, code: code);
        default:
          return StoreUnknownException(message: msg, code: code);
      }
    }

    return StoreUnknownException(message: e.toString());
  }
}

@Riverpod(keepAlive: true)
StoreDataSource storeDataSource(Ref ref) {
  return StoreFirestoreDataSource(FirebaseFirestore.instance);
}
