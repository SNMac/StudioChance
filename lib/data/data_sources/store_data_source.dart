import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/data/data_sources/firestore_data_source_base.dart';
import 'package:studio_chance/data/models/invite_info_model.dart';
import 'package:studio_chance/data/models/invite_store_preview_model.dart';
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

  /// 초대 코드로 가입 전 표시 정보를 조회한다.
  ///
  /// 코드가 없거나 삭제된 점포면 `null`을 반환한다. 만료·형식 불량·시도 한도
  /// 초과는 예외로 던진다.
  Future<InviteStorePreviewModel?> lookupInviteCode(String inviteCode);

  /// 클라이언트 기기 시각을 신뢰할 수 없는 시각 비교 로직(초대 코드 만료 등)에서
  /// 사용할 Firestore 서버 시각을 조회한다.
  Future<DateTime> getServerTime();
}

class StoreFirestoreDataSource extends FirestoreDataSourceBase
    implements StoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final _rnd = Random();

  StoreFirestoreDataSource(this._firestore, this._functions);

  @override
  String get errorLogTag => 'Store Firestore Error';

  @override
  bool isDomainException(Object e) => e is StoreException;

  @override
  Exception buildParsingException(String message) =>
      StoreDataParsingException(message: message);

  @override
  Exception mapFirebaseCode(String code, String message) => switch (code) {
    'permission-denied' || 'unauthenticated' => StorePermissionDeniedException(
      message: message,
      code: code,
    ),
    'not-found' => StoreNotFoundException(message: message, code: code),
    'already-exists' => StoreAlreadyExistsException(
      message: message,
      code: code,
    ),
    'resource-exhausted' => StoreResourceExhaustedException(
      message: message,
      code: code,
    ),
    'unavailable' ||
    'deadline-exceeded' => StoreNetworkException(message: message, code: code),
    'aborted' || 'failed-precondition' => StoreTransactionException(
      message: message,
      code: code,
    ),
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
        // deletedAt을 쓰는 경로는 반드시 inviteInfo도 함께 null로 만들어야 한다.
        // getStoreByInviteCode가 이 불변식에 기대어 초대 코드로만 조회한다.
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

      final docRef = _storeDocRef(storeId);
      await docRef.update({
        'inviteInfo': json,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // serverTimestamp는 쓰기 시점에 클라이언트가 값을 알 수 없어, 방금 만든
      // 모델의 createdAt은 null이다. 발급 직후부터 남은 유효 시간을 보여주려면
      // 서버가 확정한 값을 다시 읽어야 한다.
      final saved = await docRef.get();
      final savedInvite = saved.data()?['inviteInfo'] as Map<String, dynamic>?;
      if (savedInvite == null) {
        // 쓰기는 성공했는데 방금 쓴 필드를 다시 읽지 못했다 — 도달해선 안 되는
        // 경로다. 이 반환값의 createdAt이 비어도 화면에는 드러나지 않으므로
        // (표시는 점포 문서 재조회가 담당한다) 로그로만 알 수 있다.
        logger.w('초대 코드 생성 후 inviteInfo를 다시 읽지 못했다\nstoreId: $storeId');
        return inviteInfoModel;
      }

      return InviteInfoModel.fromJson(savedInvite);
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<InviteStorePreviewModel?> lookupInviteCode(String inviteCode) async {
    try {
      // stores read가 멤버 전용이라 클라이언트 쿼리로는 조회할 수 없다.
      // 서버가 만료 판정과 시도 한도까지 처리한다 (functions/src/invite/).
      final callable = _functions.httpsCallable('lookupInviteCode');
      // Android 플랫폼 채널은 Map<Object?, Object?>를 돌려주므로 제네릭 캐스트가
      // 런타임에 깨질 수 있다. 제네릭 없이 호출하고 방어적으로 변환한다.
      final response = await callable.call(<String, dynamic>{
        'code': inviteCode,
      });
      final data = Map<String, dynamic>.from(response.data as Map);

      if (data['ok'] != true) {
        // 도메인 실패는 HttpsError가 아니라 판별 값으로 온다. mapFirebaseCode는
        // 이 DataSource의 모든 Firestore 호출과 공유되므로 not-found·
        // deadline-exceeded에 초대 코드 전용 의미를 얹을 수 없기 때문이다.
        final failure = inviteLookupFailureOf(data['reason'] as String?);
        if (failure == null) return null;
        throw failure;
      }

      return InviteStorePreviewModel.fromJson(
        Map<String, dynamic>.from(data['store'] as Map),
      );
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
      // 클라이언트 시각으로 조용히 폴백하면 이 메서드가 막으려는 취약점이 재발하므로,
      // probe가 없으면 예외를 던져 handleFirestoreError로 흡수시킨다 (침묵 폴백 금지).
      if (probe == null) {
        throw StateError('서버 시각 조회 실패: probe 필드가 비어 있습니다.');
      }
      return probe.toDate();
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

/// Callable이 돌려준 실패 사유를 예외로 옮긴다.
///
/// `notFound`와 알 수 없는 사유는 `null`을 반환하며, 호출부는 이를 "코드 없음"으로
/// 처리한다 (현행 `getStoreByInviteCode`의 null 계약을 유지).
Exception? inviteLookupFailureOf(String? reason) => switch (reason) {
  'expired' => StoreInviteCodeExpiredException(message: '만료된 초대 코드입니다.'),
  'invalidCode' => StoreValidationException(message: '유효하지 않은 초대 코드입니다.'),
  'rateLimited' => StoreResourceExhaustedException(
    message: '초대 코드 확인을 너무 많이 시도했습니다.\n잠시 후 다시 시도해 주세요.',
  ),
  _ => null,
};

@Riverpod(keepAlive: true)
StoreDataSource storeDataSource(Ref ref) {
  return StoreFirestoreDataSource(
    FirebaseFirestore.instance,
    // Firestore·Functions 리전을 반드시 일치시킨다 (functions/src/invite/)
    FirebaseFunctions.instanceFor(region: 'asia-northeast3'),
  );
}
