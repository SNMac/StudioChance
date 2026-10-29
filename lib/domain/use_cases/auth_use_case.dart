import 'package:fpdart/fpdart.dart';
import 'package:studio_chance/common/exceptions/auth_exceptions.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/domain/entities/auth_info.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/entities/user_store_info.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/domain/repository_interfaces/auth_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';

abstract interface class AuthUseCase {
  /// 로그인 상태 변경 `Stream`
  Stream<AuthInfo?> authStateChanges();

  /// 인증 정보를 바탕으로 유저 조회/생성
  /// 앱 시작/로그인 상태 변경 시 Firebase Auth 세션과 Firestore User 문서를 연결하는
  /// 유일한 진입점. (AppAuthController에서 사용)
  Future<Either<Exception, User>> fetchOrCreateUser(AuthInfo authInfo);

  /// Google 로그인
  Future<Either<Exception, User>> signInWithGoogle();

  /// Apple 로그인
  Future<Either<Exception, User>> signInWithApple();

  /// 로그아웃
  Future<void> signOut();

  /// 계정 삭제를 막는 점포(다른 멤버가 있는 관리자 점포). 비어 있으면 삭제할 수 있다.
  /// 계정 삭제 화면을 열기 전에 확인 화면과 안내 화면 중 무엇을 보일지 정하는 데 쓴다
  Future<Either<Exception, List<StoreRef>>> findStoresBlockingDeletion();

  /// 계정 삭제. 즉시 확정되며 되돌릴 수 없다 (ADR-0005)
  /// - 다른 멤버가 있는 점포의 관리자이면 아무것도 쓰지 않고
  ///   `StoreAdminHandoverRequiredException`(막힌 점포 목록 포함)으로 실패한다.
  ///   화면을 연 뒤에 멤버가 늘었을 수 있어 [findStoresBlockingDeletion]과 별개로 다시 확인한다
  /// - 재인증하고, Apple이 연동되어 있으면 Apple 토큰을 revoke한다
  /// - 멤버인 점포는 모두 나가고, 승인 대기 중인 신청은 모두 취소한다
  /// - 혼자 쓰는 관리자 점포는 Soft Delete한다
  /// - 사용자 문서에는 닉네임만 남기고, 마지막으로 Auth 계정을 지운다
  /// - 중간에 실패하면 실패한 단계에 따라 남는 상태가 다르다 (되돌리지 않는다)
  ///   - 재인증·Apple revoke 전: 아무것도 바뀌지 않는다
  ///   - 점포 정리 중: 사용자 문서가 그대로라 다음 로그인에서 기존 사용자로 돌아온다.
  ///     일부 점포만 정리되었을 수 있고, Apple 토큰은 이미 revoke되었다
  ///     (다음 Apple 로그인에서 동의 화면이 다시 뜰 뿐 같은 계정으로 들어온다)
  ///   - 사용자 문서를 덮어쓴 뒤: 다음 로그인에서 새 사용자로 시작한다
  Future<Either<Exception, void>> delete();

  /// 재인증
  Future<Either<Exception, void>> reauthenticate();
}

class AuthUseCaseImpl implements AuthUseCase {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final StoreUseCase _storeUseCase;

  const AuthUseCaseImpl({
    required this._authRepository,
    required this._userRepository,
    required this._storeUseCase,
  });

  @override
  Stream<AuthInfo?> authStateChanges() {
    return _authRepository.authStateChanges();
  }

  @override
  Future<Either<Exception, User>> fetchOrCreateUser(AuthInfo authInfo) {
    return _userRepository.fetchOrCreateUser(authInfo);
  }

  @override
  Future<Either<Exception, User>> signInWithGoogle() async {
    final authResult = await _authRepository.signInWithGoogle();

    return authResult.fold((error) => left(error), (authInfo) async {
      return await _userRepository.fetchOrCreateUser(authInfo);
    });
  }

  @override
  Future<Either<Exception, User>> signInWithApple() async {
    final authResult = await _authRepository.signInWithApple();

    return authResult.fold((error) => left(error), (authInfo) async {
      return await _userRepository.fetchOrCreateUser(authInfo);
    });
  }

  @override
  Future<void> signOut() async {
    final currentUserResult = await _userRepository.getCurrentUser();

    // FCM 토큰 제거 실패 시에도 반드시 signOut을 실행해야 하므로 fold 후 signOut 호출
    await currentUserResult.fold((_) async {}, (user) async {
      if (user != null) {
        try {
          await _userRepository.removeCurrentDeviceFcmToken(user.id);
        } catch (_) {}
      }
    });

    await _authRepository.signOut();
  }

  @override
  Future<Either<Exception, List<StoreRef>>> findStoresBlockingDeletion() async {
    final currentUserResult = await _userRepository.getCurrentUser();

    return currentUserResult.fold((error) => Future.value(left(error)), (
      currentUser,
    ) {
      if (currentUser == null) {
        return Future.value(
          left(AuthUserNotFoundException(message: '로그인된 사용자가 없습니다.')),
        );
      }
      return _storesBlockingDeletion(currentUser).run();
    });
  }

  @override
  Future<Either<Exception, void>> delete() async {
    final currentUserResult = await _userRepository.getCurrentUser();

    return currentUserResult.fold((error) => Future.value(left(error)), (
      currentUser,
    ) {
      if (currentUser == null) {
        return Future.value(
          left(AuthUserNotFoundException(message: '로그인된 사용자가 없습니다.')),
        );
      }

      // 막힐 사람에게 재인증 창부터 띄우지 않도록 점포 확인을 먼저 한다 (둘 다 쓰기 없음)
      // 사용자 문서는 점포 정리가 끝난 뒤에 덮어쓴다 — 덮어쓴 뒤로는 다음 로그인이 새 사용자가 된다
      return _ensureNoSharedAdminStores(currentUser)
          .flatMap((_) => TaskEither(() => _authRepository.prepareDeletion()))
          .flatMap(
            (_) => _cleanUpStores(
              currentUser,
              only: {_StoreCleanup.cancelJoinRequest, _StoreCleanup.leave},
            ),
          )
          .flatMap(
            (_) => _cleanUpStores(
              currentUser,
              only: {_StoreCleanup.permanentlyDelete},
            ),
          )
          .flatMap(
            (_) => TaskEither(
              () => _userRepository.markAccountDeleted(
                currentUser.id,
                nickname: _nicknameKeptAfterDeletion(currentUser),
              ),
            ),
          )
          .flatMap((_) => TaskEither(() => _authRepository.delete()))
          .run();
    });
  }

  /// 다른 멤버가 있는 관리자 점포가 하나라도 있으면 실패한다.
  ///
  /// 관리자가 없는 점포가 남지 않도록 관리자 위임이나 점포 삭제를 먼저 하게 한다.
  /// 계정 삭제의 어떤 쓰기보다 먼저 실행해야 막혔을 때 아무것도 바뀌지 않는다.
  TaskEither<Exception, void> _ensureNoSharedAdminStores(User currentUser) {
    return _storesBlockingDeletion(currentUser).flatMap((blocked) {
      if (blocked.isEmpty) return TaskEither.right(null);

      return TaskEither.left(
        StoreAdminHandoverRequiredException(
          stores: blocked,
          message:
              '다른 멤버가 있는 관리자 점포가 있어 계정을 삭제할 수 없습니다: '
              '${blocked.map((store) => store.id).join(', ')}',
        ),
      );
    });
  }

  /// 다른 멤버가 있는 관리자 점포.
  ///
  /// 승인 대기자는 멤버가 아니므로 세지 않는다 (영구 삭제가 신청 기록까지 정리한다).
  /// 삭제 예정 점포는 다른 멤버가 있어도 막지 않는다 — 복구는 관리자만 할 수 있어
  /// 관리자가 떠나면 남겨 둘 이유가 없으므로 영구 삭제한다 (ADR-0007)
  TaskEither<Exception, List<StoreRef>> _storesBlockingDeletion(
    User currentUser,
  ) {
    final adminStoreInfos = currentUser.storeInfos.where(
      (info) => info.canManageStore,
    );

    return TaskEither.traverseList(
      adminStoreInfos.toList(),
      (info) => TaskEither(() => _storeUseCase.getMembership(info.id)).map(
        (membership) => (
          info: info,
          hasOtherMembers:
              membership?.hasMembersOtherThan(currentUser.id) ?? false,
        ),
      ),
    ).map(
      (results) => results
          .where((result) => result.hasOtherMembers)
          .map((result) => (id: result.info.id, name: result.info.name))
          .toList(),
    );
  }

  /// 점포 중 [only]에 해당하는 정리만 차례로 한다 (정리 방법은 [_StoreCleanup.of])
  ///
  /// 하나라도 실패하면 그 시점에서 나머지를 진행하지 않고 에러를 반환한다.
  TaskEither<Exception, void> _cleanUpStores(
    User currentUser, {
    required Set<_StoreCleanup> only,
  }) {
    return currentUser.storeInfos.fold(
      TaskEither<Exception, void>.right(null),
      (acc, info) {
        final cleanup = _StoreCleanup.of(info);
        if (!only.contains(cleanup)) return acc;

        return acc.flatMap(
          (_) => TaskEither(
            () => switch (cleanup) {
              _StoreCleanup.cancelJoinRequest =>
                _storeUseCase.cancelJoinRequest(info.id),
              _StoreCleanup.leave => _storeUseCase.leaveStore(info.id),
              // 관리자 계정이 사라지면 복구할 사람이 없으므로 삭제 예정을 거치지 않는다
              _StoreCleanup.permanentlyDelete =>
                _storeUseCase.permanentlyDeleteStore(info.id),
            },
          ),
        );
      },
    );
  }

  /// 계정 삭제 후 사용자 문서에 남길 닉네임 (ADR-0005)
  /// - 닉네임이 없으면 소셜 계정 이름을 닉네임 최대 길이까지만 남긴다
  String _nicknameKeptAfterDeletion(User user) {
    final nickname = user.nickname;
    if (nickname != null) return nickname;
    // 코드 유닛이 아니라 코드 포인트로 잘라야 이모지 같은 글자가 반으로 깨지지 않는다
    return String.fromCharCodes(
      user.name.trim().runes.take(maxNicknameCharCount),
    );
  }

  @override
  Future<Either<Exception, void>> reauthenticate() {
    return _authRepository.reauthenticate();
  }
}

/// 계정 삭제 때 점포마다 하는 정리
enum _StoreCleanup {
  /// 승인 대기 중. 관리자 역할로 신청했어도 아직 멤버가 아니라 점포를 삭제할 권한이 없다
  cancelJoinRequest,

  /// 관리자가 아닌 멤버. 멤버십을 남겨 두면 보이지 않는 멤버가 관리자의 계정 삭제를 막는다
  leave,

  /// 관리자. [AuthUseCaseImpl._ensureNoSharedAdminStores]를 통과했다면 혼자 쓰는 점포이거나
  /// 삭제 예정 점포다
  permanentlyDelete;

  static _StoreCleanup of(UserStoreInfo info) {
    if (info.isPending) return cancelJoinRequest;
    if (info.role == UserRole.admin) return permanentlyDelete;
    return leave;
  }
}
