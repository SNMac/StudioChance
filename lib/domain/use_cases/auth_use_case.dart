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

  /// 회원 탈퇴
  /// - 다른 멤버가 있는 점포의 관리자이면 아무것도 쓰지 않고
  ///   `StoreAdminHandoverRequiredException`(막힌 점포 목록 포함)으로 실패한다
  /// - 혼자 쓰는 관리자 점포는 탈퇴와 함께 Soft Delete한다
  Future<Either<Exception, void>> delete();

  /// 재인증
  Future<Either<Exception, void>> reauthenticate();
}

class AuthUseCaseImpl implements AuthUseCase {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final StoreUseCase _storeUseCase;

  const AuthUseCaseImpl({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required StoreUseCase storeUseCase,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _storeUseCase = storeUseCase;

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

      return _ensureNoSharedAdminStores(currentUser)
          .flatMap(
            (_) => TaskEither(
              () => _userRepository.softDeleteUser(currentUser.id),
            ),
          )
          .flatMap((_) => _softDeleteAdminStores(currentUser))
          .flatMap((_) => TaskEither(() => _authRepository.delete()))
          .run();
    });
  }

  /// 다른 멤버가 있는 관리자 점포가 하나라도 있으면 실패한다.
  ///
  /// 관리자가 없는 점포가 남지 않도록 관리자 위임이나 점포 삭제를 먼저 하게 한다.
  /// 탈퇴의 어떤 쓰기보다 먼저 실행해야 막혔을 때 아무것도 바뀌지 않는다.
  /// 승인 대기자는 멤버가 아니므로 세지 않는다 (점포 삭제가 신청 기록까지 정리한다)
  TaskEither<Exception, void> _ensureNoSharedAdminStores(User currentUser) {
    return TaskEither.traverseList(
      _adminStoreInfosOf(currentUser),
      (info) => TaskEither(() => _storeUseCase.getStore(info.id)).map(
        (store) =>
            (info: info, hasOtherMembers: (store?.memberInfos.length ?? 0) > 1),
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
              '다른 멤버가 있는 관리자 점포가 있어 탈퇴할 수 없습니다: '
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

  /// 사용자가 관리자(admin)로 속한 모든 점포를 Soft Delete 처리한다.
  ///
  /// [_ensureNoSharedAdminStores]를 통과한 뒤라 모두 혼자 쓰는 점포다.
  /// 순회하며 삭제하고, 하나라도 실패하면 그 시점에서 나머지를 진행하지 않고 에러를 반환한다.
  TaskEither<Exception, void> _softDeleteAdminStores(User currentUser) {
    final adminStoreIds = _adminStoreInfosOf(
      currentUser,
    ).map((info) => info.id);

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
