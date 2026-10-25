import 'package:fpdart/fpdart.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/domain/entities/invite_info.dart';
import 'package:studio_chance/domain/entities/invite_store_preview.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/use_cases/use_case_helpers.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/domain/entities/store_membership.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/domain/repository_interfaces/store_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';

abstract interface class StoreUseCase {
  /// 점포 생성 (생성 요청자를 Admin으로 자동 등록)
  /// - `color`: 생성자가 해당 점포를 표시할 색상
  Future<Either<Exception, Store>> createStore({
    required Store store,
    required StoreColor color,
    required String memo,
  });

  /// 점포 조회
  Future<Either<Exception, Store?>> getStore(String storeId);

  /// 점포 멤버 구성 조회 — 관리자 판정·멤버 수처럼 멤버가 한 명도 빠지면 안 되는 판단용.
  /// 없거나 삭제됐으면 null
  Future<Either<Exception, StoreMembership?>> getMembership(String storeId);

  /// 수정할 점포 조회 — 삭제됐거나 없으면 `StoreNotFoundException`으로 실패한다.
  /// 점포 수정 화면 진입과 충돌 후 다시 불러오기가 함께 쓴다 (D13)
  Future<Either<Exception, Store>> getStoreForEdit(String storeId);

  /// 초대 코드로 점포 조회 (참여 요청 전 확인용)
  Future<Either<Exception, InviteStorePreview?>> getStoreByInviteCode(
    String inviteCode,
  );

  /// 점포 참여 요청 (대기열 등록)
  /// - ADMIN 역할로는 신청할 수 없다 (`StoreAdminRoleChangeException`)
  Future<Either<Exception, void>> joinStore({
    required String storeId,
    required String storeAlias,
    required UserRole role,
    required StoreColor color,
    required String memo,
  });

  /// 멤버 가입 승인 (관리자용)
  /// - ADMIN 역할로는 승인할 수 없다 (`StoreAdminRoleChangeException`)
  Future<Either<Exception, void>> approveMember({
    required String storeId,
    required String targetUid,
    required UserRole role,
  });

  /// 멤버 제거 (관리자용) — 승인 대기자 거절 및 기존 멤버 추방에 사용
  /// - 관리자는 추방할 수 없다 (`StoreAdminRoleChangeException`)
  Future<Either<Exception, void>> removeMember({
    required String storeId,
    required String targetUid,
  });

  /// 멤버 권한 수정 (관리자용)
  /// - 관리자로 올리거나 관리자를 강등할 수 없다 (`StoreAdminRoleChangeException`).
  ///   관리자는 [delegateAdmin]으로만 바뀐다
  Future<Either<Exception, void>> updateMemberRole({
    required String storeId,
    required String targetUid,
    required UserRole newRole,
  });

  /// 관리자 위임 (관리자용) — 나를 [previousAdminRole]로 바꾸고 [targetUid]를 관리자로 올린다
  /// - [targetUid]는 점포의 스태프·뷰어여야 한다 (`StoreDelegationTargetInvalidException`)
  /// - [previousAdminRole]은 스태프나 뷰어만 가능하다
  Future<Either<Exception, void>> delegateAdmin({
    required String storeId,
    required String targetUid,
    required UserRole previousAdminRole,
  });

  /// 점포 나가기
  /// - 관리자는 나갈 수 없다 (`StoreAdminHandoverRequiredException`)
  Future<Either<Exception, void>> leaveStore(String storeId);

  /// 승인 대기 중인 가입 신청 취소
  Future<Either<Exception, void>> cancelJoinRequest(String storeId);

  /// 점포 정보 수정
  /// - [original]: 수정 폼을 연 시점의 점포. 그 뒤 다른 관리자가 설정을 먼저 저장했으면
  ///   `StoreUpdateConflictException`으로 실패한다 (D13)
  Future<Either<Exception, void>> updateStore({
    required Store original,
    required Store store,
    required StoreColor color,
    required String memo,
  });

  /// 초대 코드 생성/재생성
  Future<Either<Exception, InviteInfo>> createInviteCode(
    String storeId, {
    bool forceRegenerate = false,
  });

  /// 점포 삭제 (Soft Delete)
  Future<Either<Exception, void>> softDeleteStore(String storeId);
}

class StoreUseCaseImpl implements StoreUseCase {
  final StoreRepository _storeRepository;
  final UserRepository _userRepository;

  const StoreUseCaseImpl({
    required StoreRepository storeRepository,
    required UserRepository userRepository,
  }) : _storeRepository = storeRepository,
       _userRepository = userRepository;

  /// 현재 유저가 보유한 다른 점포와 이름이 중복되는지 검증한다.
  /// [store.id]가 [currentUser.storeInfos] 항목과 일치하면 자기 자신이므로 제외한다.
  /// (신규 생성 시 store.id는 빈 문자열이라 자연히 아무 항목도 제외되지 않는다)
  /// 또한 같은 점포 내 공간명 중복을 검증한다.
  StoreException? _findDuplicateNameError({
    required Store store,
    required User currentUser,
  }) {
    final trimmedStoreName = store.name.trim();
    final hasDuplicateStoreName = currentUser.storeInfos.any(
      (info) => info.id != store.id && info.name.trim() == trimmedStoreName,
    );
    if (hasDuplicateStoreName) {
      return StoreNameDuplicateException(message: '중복된 점포명: $trimmedStoreName');
    }

    final seenSpaceNames = <String>{};
    for (final space in store.spaceOptions) {
      final trimmed = space.name.trim();
      if (!seenSpaceNames.add(trimmed)) {
        return SpaceNameDuplicateException(message: '중복된 공간명: $trimmed');
      }
    }

    return null;
  }

  @override
  Future<Either<Exception, Store>> createStore({
    required Store store,
    required StoreColor color,
    required String memo,
  }) {
    return getCurrentUserOrThrow(_userRepository).flatMap((currentUser) {
      final duplicateError = _findDuplicateNameError(
        store: store,
        currentUser: currentUser,
      );
      if (duplicateError != null) {
        return TaskEither<Exception, Store>.left(duplicateError);
      }

      final adminMemberInfo = StoreMemberInfo(
        user: currentUser,
        role: UserRole.admin,
      );

      final storeWithAdmin = store.copyWith(
        memberInfos: [adminMemberInfo],
        waitingMemberInfos: [],
      );

      return TaskEither(
        () => _storeRepository.createStore(
          store: storeWithAdmin,
          color: color,
          memo: memo,
        ),
      );
    }).run();
  }

  @override
  Future<Either<Exception, Store?>> getStore(String storeId) {
    return _storeRepository.getStore(storeId);
  }

  @override
  Future<Either<Exception, StoreMembership?>> getMembership(String storeId) {
    return _storeRepository.getMembership(storeId);
  }

  @override
  Future<Either<Exception, Store>> getStoreForEdit(String storeId) async {
    final result = await _storeRepository.getStore(storeId);
    return result.flatMap<Store>(
      (store) => store == null
          ? left(StoreNotFoundException(message: '삭제된 점포: $storeId'))
          : right(store),
    );
  }

  @override
  Future<Either<Exception, InviteStorePreview?>> getStoreByInviteCode(
    String inviteCode,
  ) {
    return _storeRepository.getStoreByInviteCode(inviteCode);
  }

  @override
  Future<Either<Exception, void>> joinStore({
    required String storeId,
    required String storeAlias,
    required UserRole role,
    required StoreColor color,
    required String memo,
  }) {
    return _rejectAdminRole(role, 'ADMIN 역할로 가입 신청할 수 없습니다')
        .flatMap((_) => getCurrentUserOrThrow(_userRepository))
        .flatMap((currentUser) {
          return TaskEither(
            () => _storeRepository.requestJoinStore(
              storeId: storeId,
              uid: currentUser.id,
              role: role,
              color: color,
              storeAlias: storeAlias,
              memo: memo,
            ),
          );
        })
        .run();
  }

  @override
  Future<Either<Exception, void>> approveMember({
    required String storeId,
    required String targetUid,
    required UserRole role,
  }) {
    return _rejectAdminRole(role, 'ADMIN 역할로 승인할 수 없습니다: $targetUid')
        .flatMap(
          (_) => TaskEither(
            () => _storeRepository.approveMember(
              storeId: storeId,
              uid: targetUid,
              role: role,
            ),
          ),
        )
        .run();
  }

  @override
  Future<Either<Exception, void>> removeMember({
    required String storeId,
    required String targetUid,
  }) {
    return _ensureNotAdmin(storeId: storeId, uid: targetUid)
        .flatMap(
          (_) => TaskEither(
            () =>
                _storeRepository.removeMember(storeId: storeId, uid: targetUid),
          ),
        )
        .run();
  }

  @override
  Future<Either<Exception, void>> updateMemberRole({
    required String storeId,
    required String targetUid,
    required UserRole newRole,
  }) {
    return _rejectAdminRole(newRole, '관리자로 올릴 수 없습니다: $targetUid')
        .flatMap((_) => _ensureNotAdmin(storeId: storeId, uid: targetUid))
        .flatMap(
          (_) => TaskEither(
            () => _storeRepository.updateMemberRole(
              storeId: storeId,
              uid: targetUid,
              newRole: newRole,
            ),
          ),
        )
        .run();
  }

  @override
  Future<Either<Exception, void>> delegateAdmin({
    required String storeId,
    required String targetUid,
    required UserRole previousAdminRole,
  }) {
    if (previousAdminRole != UserRole.staff &&
        previousAdminRole != UserRole.viewer) {
      return Future.value(
        left(
          StoreValidationException(
            message: '이전 관리자는 스태프나 뷰어가 되어야 합니다: ${previousAdminRole.name}',
          ),
        ),
      );
    }

    return getCurrentUserOrThrow(_userRepository).flatMap((currentUser) {
      if (currentUser.id == targetUid) {
        return TaskEither<Exception, void>.left(
          StoreDelegationTargetInvalidException(message: '자기 자신에게 위임할 수 없습니다'),
        );
      }

      // 대상이 아직 스태프·뷰어인지는 Repository가 트랜잭션 안에서 다시 확인한다
      return TaskEither(
        () => _storeRepository.delegateAdmin(
          storeId: storeId,
          fromUid: currentUser.id,
          toUid: targetUid,
          previousAdminRole: previousAdminRole,
        ),
      );
    }).run();
  }

  @override
  Future<Either<Exception, void>> leaveStore(String storeId) {
    return getCurrentUserOrThrow(_userRepository).flatMap((currentUser) {
      if (currentUser.roleIn(storeId) == UserRole.admin) {
        final name = currentUser.storeInfoOf(storeId)?.name ?? '';
        return TaskEither<Exception, void>.left(
          StoreAdminHandoverRequiredException(
            stores: [(id: storeId, name: name)],
            message: '관리자는 점포를 나갈 수 없습니다: $storeId',
          ),
        );
      }

      return _removeSelf(storeId: storeId, uid: currentUser.id);
    }).run();
  }

  @override
  Future<Either<Exception, void>> cancelJoinRequest(String storeId) {
    return getCurrentUserOrThrow(_userRepository).flatMap((currentUser) {
      if (currentUser.storeInfoOf(storeId)?.isPending != true) {
        return TaskEither<Exception, void>.left(
          StoreValidationException(message: '승인 대기 중인 가입 신청이 없습니다: $storeId'),
        );
      }

      return _removeSelf(storeId: storeId, uid: currentUser.id);
    }).run();
  }

  /// [role]이 관리자이면 실패한다. 관리자는 위임으로만 생긴다 (ADR-0004)
  TaskEither<Exception, void> _rejectAdminRole(UserRole role, String message) {
    return role == UserRole.admin
        ? TaskEither.left(StoreAdminRoleChangeException(message: message))
        : TaskEither.right(null);
  }

  /// [uid]가 점포의 관리자이면 실패한다. 관리자는 위임으로만 바뀐다 (ADR-0004)
  TaskEither<Exception, void> _ensureNotAdmin({
    required String storeId,
    required String uid,
  }) {
    return TaskEither(() => _storeRepository.getMembership(storeId)).flatMap((
      membership,
    ) {
      if (membership?.roleOf(uid) != UserRole.admin) {
        return TaskEither.right(null);
      }

      return TaskEither.left(
        StoreAdminRoleChangeException(
          message: '관리자의 역할은 위임으로만 바꿀 수 있습니다: $uid',
        ),
      );
    });
  }

  /// 본인을 점포에서 지운다 (점포 나가기·신청 취소).
  ///
  /// 반드시 본인 계정으로 직접 쓴다. Rules는 본인 항목 삭제만 허용하고, 알림 함수
  /// (notifyOnMembershipChange)는 쓴 사람과 지워진 uid가 같은지로 나가기·신청 취소를
  /// 추방·거절과 구분한다 — 다른 경로(Function 등)가 대신 쓰면 추방·거절로 알린다
  TaskEither<Exception, void> _removeSelf({
    required String storeId,
    required String uid,
  }) {
    return TaskEither(
      () => _storeRepository.removeMember(storeId: storeId, uid: uid),
    );
  }

  @override
  Future<Either<Exception, void>> updateStore({
    required Store original,
    required Store store,
    required StoreColor color,
    required String memo,
  }) {
    return getCurrentUserOrThrow(_userRepository).flatMap((currentUser) {
      final duplicateError = _findDuplicateNameError(
        store: store,
        currentUser: currentUser,
      );
      if (duplicateError != null) {
        return TaskEither<Exception, void>.left(duplicateError);
      }

      return TaskEither(
        () => _storeRepository.updateStore(
          original: original,
          store: store,
          uid: currentUser.id,
          color: color,
          memo: memo,
        ),
      );
    }).run();
  }

  @override
  Future<Either<Exception, InviteInfo>> createInviteCode(
    String storeId, {
    bool forceRegenerate = false,
  }) {
    return _storeRepository.createInviteCode(
      storeId,
      forceRegenerate: forceRegenerate,
    );
  }

  @override
  Future<Either<Exception, void>> softDeleteStore(String storeId) {
    return _storeRepository.softDeleteStore(storeId);
  }
}
