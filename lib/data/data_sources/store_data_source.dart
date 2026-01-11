import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/data/models/invite_info_model.dart';
import 'package:studio_chance/data/models/store_model.dart';

part 'store_data_source.g.dart';

abstract interface class StoreDataSource {
  /// 점포 생성
  Future<StoreModel> createStore(StoreModel store, String uid);

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
  Future<void> addWaitingMember(String storeId, String uid, String role);

  /// 가입 승인
  Future<void> approveMemberWithBatch(String storeId, String uid, String role);

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
  Future<StoreModel> createStore(StoreModel store, String uid) async {
    try {
      final batch = _firestore.batch();
      final serverTimestamp = FieldValue.serverTimestamp();

      final docRef = _firestore.collection('stores').doc();

      final json = store.toJson();
      json['createdAt'] = serverTimestamp;
      json['updatedAt'] = serverTimestamp;

      batch.set(docRef, json);

      final userRef = _firestore.collection('users').doc(uid);
      batch.update(userRef, {
        'storeIds': FieldValue.arrayUnion([docRef.id]),
        'updatedAt': serverTimestamp,
      });

      await batch.commit();

      final now = DateTime.now();
      return store.copyWith(id: docRef.id, createdAt: now, updatedAt: now);
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
      await _firestore.collection('stores').doc(storeId).update({
        'memberIds.$uid': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
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
        'memberIds.$uid': FieldValue.delete(),
        'waitingMemberIds.$uid': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final userRef = _firestore.collection('users').doc(uid);
      batch.update(userRef, {
        'storeIds': FieldValue.arrayRemove([storeId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<void> addWaitingMember(String storeId, String uid, String role) async {
    try {
      await _firestore.collection('stores').doc(storeId).update({
        'waitingMemberIds.$uid': role,
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
    String role,
  ) async {
    try {
      final batch = _firestore.batch();
      final storeRef = _firestore.collection('stores').doc(storeId);
      final userRef = _firestore.collection('users').doc(uid);

      batch.update(storeRef, {
        'waitingMemberIds.$uid': FieldValue.delete(),
        'memberIds.$uid': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.update(userRef, {
        'storeIds': FieldValue.arrayUnion([storeId]),
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
      final hardDeleteDate = DateTime.now().add(const Duration(days: 7));
      await _firestore.collection('stores').doc(storeId).update({
        'deletedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(hardDeleteDate),
        'updatedAt': FieldValue.serverTimestamp(),
        'inviteInfoModel': null,
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
        final currentStore = await getStore(storeId);
        if (currentStore == null) {
          throw StoreNotFoundException(message: '점포를 찾을 수 없습니다.');
        }

        final currentInvite = currentStore.inviteInfoModel;
        if (currentInvite != null &&
            currentInvite.expiresAt.isAfter(DateTime.now())) {
          return currentInvite;
        }
      }

      final newCode = _generateRandomCode(6);

      final tempModel = InviteInfoModel(
        inviteCode: newCode,
        createdAt: DateTime.now(),
      );
      final json = tempModel.toJson();
      json['createdAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('stores').doc(storeId).update({
        'inviteInfoModel': json,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return InviteInfoModel(inviteCode: newCode, createdAt: DateTime.now());
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  @override
  Future<StoreModel?> getStoreByInviteCode(String inviteCode) async {
    try {
      final validThreshold = DateTime.now().subtract(
        const Duration(minutes: 15),
      );

      final querySnapshot = await _firestore
          .collection('stores')
          .where('inviteInfoModel.inviteCode', isEqualTo: inviteCode)
          .where('deletedAt', isNull: true)
          .where('inviteInfoModel.createdAt', isGreaterThan: validThreshold)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final docSnapshot = querySnapshot.docs.first;
      final data = docSnapshot.data();
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
