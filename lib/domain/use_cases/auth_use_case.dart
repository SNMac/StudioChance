import 'package:fpdart/fpdart.dart';
import 'package:studio_chance/common/exceptions/auth_exceptions.dart';
import 'package:studio_chance/domain/entities/auth_info.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/repository_interfaces/auth_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';

abstract interface class AuthUseCase {
  /// 로그인 상태 변경 `Stream`
  Stream<AuthInfo?> authStateChanges();

  /// Google 로그인
  Future<Either<Exception, User>> signInWithGoogle();

  /// Apple 로그인
  Future<Either<Exception, User>> signInWithApple();

  /// 로그아웃
  Future<void> signOut();

  /// 회원 탈퇴
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
    await currentUserResult.fold(
      (_) async {},
      (user) async {
        if (user != null) {
          try {
            await _userRepository.removeCurrentDeviceFcmToken(user.id);
          } catch (_) {}
        }
      },
    );

    await _authRepository.signOut();
  }

  @override
  Future<Either<Exception, void>> delete() async {
    final currentUserResult = await _userRepository.getCurrentUser();

    return currentUserResult.fold(
      (error) => Future.value(left(error)),
      (currentUser) {
        if (currentUser == null) {
          return Future.value(
            left(AuthUserNotFoundException(message: '로그인된 사용자가 없습니다.')),
          );
        }

        return TaskEither(() => _userRepository.softDeleteUser(currentUser.id))
            .flatMap((_) => _softDeleteAdminStores(currentUser))
            .flatMap((_) => TaskEither(() => _authRepository.delete()))
            .run();
      },
    );
  }

  /// 사용자가 관리자(admin)로 속한 모든 점포를 Soft Delete 처리한다.
  ///
  /// 계정 삭제 시 관리자 소유 점포 레코드가 Firestore에 잔존하지 않도록
  /// 순회하며 삭제하고, 하나라도 실패하면 그 시점에서 나머지를 진행하지 않고 에러를 반환한다.
  TaskEither<Exception, void> _softDeleteAdminStores(User currentUser) {
    final adminStoreIds = currentUser.storeInfos
        .where((info) => info.role == UserRole.admin)
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
