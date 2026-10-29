import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/data/data_sources/callable_helpers.dart';
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

  /// 점포 단일 조회. 삭제 예정 점포도 돌려준다 (`deletedAt`으로 구분)
  Future<StoreModel?> getStore(String storeId);

  /// 점포 정보 수정
  /// - [isUnchanged]: 트랜잭션에서 읽은 저장 직전 문서가 수정 폼을 연 시점과 같은지 판정한다.
  ///   false면 다른 관리자가 먼저 저장한 것이므로 [StoreUpdateConflictException]을 던지고
  ///   쓰지 않는다 (D13). 비교 규칙은 legacy fallback을 아는 Repository가 정한다.
  /// - `data`에 `name`이 포함되면 저장 시점의 멤버+대기 멤버 중 사용자 문서에 그 점포
  ///   항목이 있는 사람의 `storeById.{storeId}.name` 캐시를 함께 동기화한다.
  Future<void> updateStore(
    String storeId,
    Map<String, dynamic> data, {
    required bool Function(StoreModel current) isUnchanged,
  });

  /// 점포 삭제 — 삭제 예정 점포로 만든다 (ADR-0007)
  /// - 멤버의 `storeById.{storeId}` 항목은 남기고 `deletedAt`만 표시한다. 그래야 멤버
  ///   화면에 남은 기간이 보이고, 복구할 때 점포 색상·점포 메모가 그대로 돌아온다
  /// - 승인 대기 중인 신청은 이때 정리한다 (대기 명단과 신청자의 `storeById` 항목)
  /// - 이미 삭제 예정이면 아무것도 쓰지 않는다
  /// - `expiresAt`이 지나면 TTL이 점포 문서를 지우고, Functions의 `cascadeStoreDelete`가
  ///   예약과 멤버의 점포 항목을 지운다
  Future<void> softDeleteStore(String storeId);

  /// 점포 복구 — 삭제 예정 표시를 점포 문서와 멤버의 `storeById` 항목에서 지운다.
  /// 삭제 예정이 아니면 아무것도 쓰지 않는다
  Future<void> restoreStore(String storeId);

  /// 영구 삭제 — 점포 문서와 멤버·승인 대기자의 `storeById.{storeId}` 항목을 함께 지운다.
  /// 예약은 Functions의 `cascadeStoreDelete`가 지운다. 그 함수도 항목을 지우지만 트리거라
  /// 늦게 돌아, 여기서 지우지 않으면 바로 다시 읽은 점포 목록에 지운 점포가 남는다
  Future<void> permanentlyDeleteStore(String storeId);

  /// 멤버 역할 수정
  Future<void> updateMemberRole(String storeId, String uid, String role);

  /// 관리자 위임 — [fromUid]를 [previousRole]로, [toUid]를 관리자로 한 트랜잭션에서 바꾼다
  /// - [previousRole]: JSON 역할 값 (`STAFF`/`VIEWER`)
  /// - [fromUid]가 관리자가 아니면 `StorePermissionDeniedException`,
  ///   [toUid]가 스태프·뷰어가 아니면 `StoreDelegationTargetInvalidException`
  Future<void> delegateAdmin(
    String storeId, {
    required String fromUid,
    required String toUid,
    required String previousRole,
  });

  /// 멤버 삭제 — 추방·거절(관리자가 씀)과 나가기·신청 취소(본인이 씀)가 함께 쓴다.
  /// 지우는 항목이 없는 쪽 맵은 바뀌지 않으므로 Rules의 본인 규칙도 통과한다
  Future<void> removeMember(String storeId, String uid);

  /// 가입 신청 (대기열 추가 + 사용자 점포 정보 저장)
  Future<void> requestJoinWithBatch(
    String storeId,
    String uid,
    StoreMemberInfoModel memberInfo,
    UserStoreInfoModel userStoreInfo,
  );

  /// 가입 승인 (waitingMemberById → memberById 이동)
  /// - 승인된 역할을 users/{uid}.storeById.{storeId}.role에도 동기화하고,
  ///   승인 대기 표시(isPending)를 지운다.
  Future<void> approveMember(
    String storeId,
    String uid,
    StoreMemberInfoModel memberInfo,
  );

  /// 초대 코드를 발급한다. 유효한 코드가 남아 있으면 그 코드를 돌려주고,
  /// [forceRegenerate]가 true면 새 코드로 바꾼다 (Callable `issueInviteCode`).
  Future<InviteInfoModel> issueInviteCode(
    String storeId, {
    bool forceRegenerate = false,
  });

  /// 초대 코드로 가입 전 표시 정보를 조회한다.
  ///
  /// 코드가 없거나 삭제된 점포면 `null`을 반환한다. 만료·형식 불량·시도 한도
  /// 초과는 예외로 던진다.
  Future<InviteStorePreviewModel?> lookupInviteCode(String inviteCode);
}

class StoreFirestoreDataSource extends FirestoreDataSourceBase
    implements StoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

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
    Map<String, dynamic> data, {
    required bool Function(StoreModel current) isUnchanged,
  }) async {
    try {
      final storeRef = _storeDocRef(storeId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(storeRef);
        final json = snapshot.data();
        if (!snapshot.exists || json == null || json['deletedAt'] != null) {
          throw StoreNotFoundException(message: '수정할 점포가 없습니다: $storeId');
        }
        json['id'] = snapshot.id;
        final current = StoreModel.fromJson(json);

        if (!isUnchanged(current)) {
          throw StoreUpdateConflictException(
            message: '폼을 연 뒤 점포 설정이 바뀌었습니다: $storeId',
          );
        }

        // 트랜잭션은 모든 읽기가 쓰기보다 먼저여야 하므로 이름 캐시 대상부터 읽는다
        final newName = data['name'] as String?;
        // 폼을 연 뒤 들어온 가입 신청까지 반영되도록 저장 시점의 멤버 목록을 쓴다
        final cacheTargets = newName == null
            ? const <String>{}
            : await _uidsWithStoreEntry(transaction, storeId, {
                ...current.memberById.keys,
                ...current.waitingMemberById.keys,
              });

        transaction.update(storeRef, {
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        for (final uid in cacheTargets) {
          transaction.update(_userRef(uid), {
            'storeById.$storeId.name': newName,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
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
  Future<void> delegateAdmin(
    String storeId, {
    required String fromUid,
    required String toUid,
    required String previousRole,
  }) async {
    try {
      final storeRef = _storeDocRef(storeId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(storeRef);
        final json = snapshot.data();
        if (!snapshot.exists || json == null || json['deletedAt'] != null) {
          throw StoreNotFoundException(message: '위임할 점포가 없습니다: $storeId');
        }
        json['id'] = snapshot.id;
        final current = StoreModel.fromJson(json);

        if (current.memberById[fromUid]?.role != UserRole.admin) {
          throw StorePermissionDeniedException(
            message: '관리자가 아니라 위임할 수 없습니다: $fromUid',
          );
        }
        final targetRole = current.memberById[toUid]?.role;
        if (targetRole != UserRole.staff && targetRole != UserRole.viewer) {
          throw StoreDelegationTargetInvalidException(
            message: '위임 대상이 스태프·뷰어가 아닙니다: $toUid ($targetRole)',
          );
        }

        // 트랜잭션은 모든 읽기가 쓰기보다 먼저여야 하므로 역할 캐시 대상부터 읽는다
        final cacheTargets = await _uidsWithStoreEntry(transaction, storeId, [
          fromUid,
          toUid,
        ]);

        // 두 역할을 한 번에 바꿔야 Rules의 관리자 1명 검증을 통과한다 (ADR-0004)
        transaction.update(storeRef, {
          'memberById.$fromUid.role': previousRole,
          'memberById.$toUid.role': UserRole.admin.jsonValue,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        if (cacheTargets.contains(fromUid)) {
          transaction.update(_userRef(fromUid), {
            'storeById.$storeId.role': previousRole,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        if (cacheTargets.contains(toUid)) {
          transaction.update(_userRef(toUid), {
            'storeById.$storeId.role': UserRole.admin.jsonValue,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
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
        // 이제 멤버이므로 승인 대기 표시를 지운다 (없으면 승인된 점포로 읽힌다)
        'storeById.$storeId.isPending': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> softDeleteStore(String storeId) async {
    try {
      final storeRef = _storeDocRef(storeId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(storeRef);
        final json = snapshot.data();
        if (!snapshot.exists || json == null) {
          throw StoreNotFoundException(message: '삭제할 점포가 없습니다: $storeId');
        }
        if (json['deletedAt'] != null) return;
        json['id'] = snapshot.id;
        final current = StoreModel.fromJson(json);

        // 트랜잭션은 모든 읽기가 쓰기보다 먼저여야 하므로 사용자 문서부터 읽는다
        final memberUids = await _uidsWithStoreEntry(
          transaction,
          storeId,
          current.memberById.keys,
        );
        final applicantUids = await _uidsWithStoreEntry(
          transaction,
          storeId,
          current.waitingMemberById.keys,
        );

        // 남은 기간은 서버 시각인 deletedAt으로 센다. expiresAt은 TTL에만 쓰므로 기기 시각에
        // 여유를 더해 TTL이 화면에 보인 기한보다 먼저 지우지 않게 한다 (여유와 Rules의 허용
        // 범위는 storeDeletionExpiryBufferDays 주석)
        final expiresAt = Timestamp.fromDate(
          DateTime.now().add(
            const Duration(
              days: storeSoftDeleteDays + storeDeletionExpiryBufferDays,
            ),
          ),
        );
        transaction.update(storeRef, {
          'deletedAt': FieldValue.serverTimestamp(),
          'expiresAt': expiresAt,
          'updatedAt': FieldValue.serverTimestamp(),
          // memberById는 지우지 않는다. 멤버는 삭제 예정 점포를 계속 읽고, 점포 삭제
          // 알림 함수(notifyOnStoreUpdate)가 알림 받을 사람을 이 문서에서 읽는다.
          // 같은 쓰기에서 비운 승인 대기 명단도 알림 함수가 변경 전 문서에서 읽는다.
          // deletedAt을 쓰는 경로는 반드시 inviteInfo도 함께 null로 만들어야 한다.
          // lookupInviteCode Callable(functions/src/invite/lookup_invite_code.ts)이
          // 이 불변식에 기대어 초대 코드로만 조회한다.
          'inviteInfo': null,
          for (final uid in current.waitingMemberById.keys)
            'waitingMemberById.$uid': FieldValue.delete(),
        });
        for (final uid in memberUids) {
          transaction.update(_userRef(uid), {
            'storeById.$storeId.deletedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        for (final uid in applicantUids) {
          transaction.update(_userRef(uid), {
            'storeById.$storeId': FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> restoreStore(String storeId) async {
    try {
      final storeRef = _storeDocRef(storeId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(storeRef);
        final json = snapshot.data();
        if (!snapshot.exists || json == null) {
          throw StoreNotFoundException(message: '복구할 점포가 없습니다: $storeId');
        }
        if (json['deletedAt'] == null) return;
        json['id'] = snapshot.id;
        final current = StoreModel.fromJson(json);

        // 삭제 예정 중에 나간 멤버는 memberById에 없으므로 돌아오지 않는다
        final memberUids = await _uidsWithStoreEntry(
          transaction,
          storeId,
          current.memberById.keys,
        );

        transaction.update(storeRef, {
          'deletedAt': FieldValue.delete(),
          'expiresAt': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        for (final uid in memberUids) {
          transaction.update(_userRef(uid), {
            'storeById.$storeId.deletedAt': FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<void> permanentlyDeleteStore(String storeId) async {
    try {
      final storeRef = _storeDocRef(storeId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(storeRef);
        final json = snapshot.data();
        if (!snapshot.exists || json == null) return;
        json['id'] = snapshot.id;
        final current = StoreModel.fromJson(json);

        final uids = await _uidsWithStoreEntry(transaction, storeId, {
          ...current.memberById.keys,
          ...current.waitingMemberById.keys,
        });

        transaction.delete(storeRef);
        for (final uid in uids) {
          transaction.update(_userRef(uid), {
            'storeById.$storeId': FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _firestore.collection('users').doc(uid);

  /// [uids] 중 사용자 문서에 [storeId] 점포 항목이 있는 사람.
  ///
  /// 항목이 없는 사람에게 `storeById.{storeId}.필드` 점 경로로 쓰면 role 없는 항목이
  /// 생겨 그 사용자를 읽는 점포 조회가 전부 파싱에 실패하므로 미리 거른다 (D13 참고).
  /// 트랜잭션은 모든 읽기가 쓰기보다 먼저여야 하므로 쓰기 전에 부른다
  Future<Set<String>> _uidsWithStoreEntry(
    Transaction transaction,
    String storeId,
    Iterable<String> uids,
  ) async {
    final withEntry = <String>{};
    for (final uid in uids) {
      final userSnapshot = await transaction.get(_userRef(uid));
      final storeById = userSnapshot.data()?['storeById'];
      if (storeById is Map && storeById.containsKey(storeId)) {
        withEntry.add(uid);
      }
    }
    return withEntry;
  }

  @override
  Future<InviteInfoModel> issueInviteCode(
    String storeId, {
    bool forceRegenerate = false,
  }) async {
    try {
      // 클라이언트는 Rules상 inviteInfo를 쓸 수 없다. 발급 시각과 재사용 판정을
      // 서버 시각으로 정하기 위함이다 (functions/src/invite/issue_invite_code.ts, ADR-0006).
      // 권한 없음·점포 없음은 HttpsError로 와서 mapFirebaseCode가 그대로 옮긴다.
      final data = await _functions.callForMap('issueInviteCode', {
        'storeId': storeId,
        'forceRegenerate': forceRegenerate,
      });

      return InviteInfoModel(
        inviteCode: data['inviteCode'] as String,
        createdAt: dateTimeFromCallableMillis(data['createdAtMillis']),
      );
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }

  @override
  Future<InviteStorePreviewModel?> lookupInviteCode(String inviteCode) async {
    try {
      // stores read가 멤버 전용이라 클라이언트 쿼리로는 조회할 수 없다.
      // 서버가 만료 판정과 시도 한도까지 처리한다 (functions/src/invite/).
      final data = await _functions.callForMap('lookupInviteCode', {
        'code': inviteCode,
      });

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
