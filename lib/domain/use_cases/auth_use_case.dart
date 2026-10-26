import 'package:fpdart/fpdart.dart';
import 'package:studio_chance/common/exceptions/auth_exceptions.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
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

  /// 계정 삭제. 즉시 확정되며 되돌릴 수 없다 (ADR-0005)
  /// - 다른 멤버가 있는 점포의 관리자이면 아무것도 쓰지 않고
  ///   `StoreAdminHandoverRequiredException`(막힌 점포 목록 포함)으로 실패한다
  /// - 재인증하고, Apple이 연동되어 있으면 Apple 토큰을 revoke한다
  /// - 멤버인 점포는 모두 나가고, 승인 대기 중인 신청은 모두 취소한다
  /// - 혼자 쓰는 관리자 점포는 Soft Delete한다
  /// - 사용자 문서에는 닉네임만 남기고, 마지막으로 Auth 계정을 지운다
  /// - 중간에 실패해 Auth 계정이 남으면 다음 로그인에서 새 사용자로 시작한다
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
          .flatMap((_) => _leaveAllStores(currentUser))
          .flatMap((_) => _softDeleteAdminStores(currentUser))
          .flatMap(
            (_) => TaskEither(
              () => _userRepository.markAccountDeleted(currentUser),
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
  /// 승인 대기자는 멤버가 아니므로 세지 않는다 (점포 삭제가 신청 기록까지 정리한다)
  TaskEither<Exception, void> _ensureNoSharedAdminStores(User currentUser) {
    return TaskEither.traverseList(
      _adminStoreInfosOf(currentUser),
      (info) => TaskEither(() => _storeUseCase.getMembership(info.id)).map(
        (membership) => (
          info: info,
          hasOtherMembers:
              membership?.hasMembersOtherThan(currentUser.id) ?? false,
        ),
      ),
    ).flatMap((results) {
      final blocked = results
          .where((result) => result.hasOtherMembers)
          .map((result) => (id: result.info.id, name: result.info.name))
          .toList();
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

  /// 승인 대기 점포는 아직 관리자가 아니라 삭제 권한이 없으므로 제외한다
  List<UserStoreInfo> _adminStoreInfosOf(User currentUser) => currentUser
      .memberStoreInfos
      .where((info) => info.role == UserRole.admin)
      .toList();

  /// 관리자가 아닌 점포에서 모두 빠진다: 멤버이면 점포 나가기, 승인 대기 중이면 신청 취소
  ///
  /// 멤버십을 남겨 두면 보이지 않는 멤버가 관리자의 계정 삭제를 막는다 (ADR-0005).
  /// 하나라도 실패하면 그 시점에서 나머지를 진행하지 않고 에러를 반환한다.
  TaskEither<Exception, void> _leaveAllStores(User currentUser) {
    return currentUser.storeInfos.fold(
      TaskEither<Exception, void>.right(null),
      (acc, info) => acc.flatMap((_) {
        if (info.isPending) {
          return TaskEither(() => _storeUseCase.cancelJoinRequest(info.id));
        }
        if (info.role == UserRole.admin) return TaskEither.right(null);
        return TaskEither(() => _storeUseCase.leaveStore(info.id));
      }),
    );
  }

  /// 사용자가 관리자(admin)로 속한 모든 점포를 Soft Delete 처리한다.
  ///
  /// [_ensureNoSharedAdminStores]를 통과한 뒤라 모두 혼자 쓰는 점포다.
  /// 순회하며 삭제하고, 하나라도 실패하면 그 시점에서 나머지를 진행하지 않고 에러를 반환한다.
  TaskEither<Exception, void> _softDeleteAdminStores(User currentUser) {
    final adminStoreIds = _adminStoreInfosOf(currentUser)
        .map((info) => info.id);

    return adminStoreIds.fold(
      TaskEither<Exception, void>.right(null),
      (acc, storeId) => acc.flatMap(
        (_) => TaskEither(() => _storeUseCase.softDeleteStore(storeId)),
      ),
    );
  }

  @override
  Future<Either<Exception, void>> reauthenticate() {
    return _authRepository.reauthenticate();
  }
}
