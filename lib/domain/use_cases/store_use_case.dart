import 'package:fpdart/fpdart.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/domain/entities/invite_info.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/use_cases/use_case_helpers.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
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

  /// 초대 코드로 점포 조회 (참여 요청 전 확인용)
  Future<Either<Exception, Store?>> getStoreByInviteCode(String inviteCode);

  /// 점포 참여 요청 (대기열 등록)
  Future<Either<Exception, void>> joinStore({
    required String storeId,
    required String storeAlias,
    required UserRole role,
    required StoreColor color,
    required String memo,
  });

  /// 멤버 가입 승인 (관리자용)
  Future<Either<Exception, void>> approveMember({
    required String storeId,
    required String targetUid,
    required UserRole role,
  });

  /// 멤버 권한 수정 (관리자용)
  Future<Either<Exception, void>> updateMemberRole({
    required String storeId,
    required String targetUid,
    required UserRole newRole,
  });

  /// 점포 정보 수정
  Future<Either<Exception, void>> updateStore({
    required Store store,
    required StoreColor color,
    required String memo,
  });

  /// 초대 코드 생성/재생성
  Future<Either<Exception, InviteInfo>> createInviteCode(
    String storeId, {
    bool forceRegenerate = false,
  });
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

    final spaceNames = store.spaceOptions.map((s) => s.name.trim()).toList();
    final hasDuplicateSpaceName = spaceNames.toSet().length != spaceNames.length;
    if (hasDuplicateSpaceName) {
      return SpaceNameDuplicateException(message: '중복된 공간명: ${store.name}');
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
  Future<Either<Exception, Store?>> getStoreByInviteCode(String inviteCode) {
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
    return getCurrentUserOrThrow(_userRepository).flatMap((currentUser) {
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
    }).run();
  }

  @override
  Future<Either<Exception, void>> approveMember({
    required String storeId,
    required String targetUid,
    required UserRole role,
  }) {
    // 실제로는 여기서 '현재 유저가 관리자 권한이 있는지' 체크하는 로직이 들어갈 수 있습니다.
    return TaskEither(
      () => _storeRepository.approveMember(
        storeId: storeId,
        uid: targetUid,
        role: role,
      ),
    ).run();
  }

  @override
  Future<Either<Exception, void>> updateMemberRole({
    required String storeId,
    required String targetUid,
    required UserRole newRole,
  }) {
    return TaskEither(
      () => _storeRepository.updateMemberRole(
        storeId: storeId,
        uid: targetUid,
        newRole: newRole,
      ),
    ).run();
  }

  @override
  Future<Either<Exception, void>> updateStore({
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
}
