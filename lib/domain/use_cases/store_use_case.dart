import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/common/exceptions/auth_exceptions.dart';

import 'package:studio_chance/data/repositories/store_repository_impl.dart';
import 'package:studio_chance/domain/entities/invite_info.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/repository_interfaces/store_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';
import 'package:studio_chance/data/repositories/user_repository_impl.dart';

part 'store_use_case.g.dart';

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

  @override
  Future<Either<Exception, Store>> createStore({
    required Store store,
    required StoreColor color,
    required String memo,
  }) {
    return _getCurrentUser().flatMap((currentUser) {
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
    return _getCurrentUser().flatMap((currentUser) {
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
    return _getCurrentUser().flatMap((currentUser) {
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

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  /// 현재 로그인한 유저를 가져오는 `TaskEither`
  TaskEither<Exception, User> _getCurrentUser() {
    return TaskEither.tryCatch(() async {
      final result = await _userRepository.getCurrentUser();
      return result.fold((left) => throw left, (right) {
        if (right == null) {
          throw AuthUserNotFoundException(message: '로그인 정보를 찾을 수 없습니다.');
        }
        return right;
      });
    }, (error, stackTrace) => error is Exception ? error : Exception(error));
  }
}

@riverpod
StoreUseCase storeUseCase(Ref ref) {
  final storeRepository = ref.watch(storeRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);

  return StoreUseCaseImpl(
    storeRepository: storeRepository,
    userRepository: userRepository,
  );
}
