import 'package:fpdart/fpdart.dart';
import 'package:studio_chance/common/exceptions/auth_exceptions.dart';
import 'package:studio_chance/common/exceptions/user_exceptions.dart';
import 'package:studio_chance/domain/entities/auth_info.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/repository_interfaces/auth_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';

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

  const AuthUseCaseImpl({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository;

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
      (error) async => left(error),
      (currentUser) async {
        if (currentUser == null) {
          return left(AuthUserNotFoundException(message: '로그인된 사용자가 없습니다.'));
        }

        try {
          await _userRepository.softDeleteUser(currentUser.id);
        } catch (e) {
          return left(
            e is Exception ? e : UserUnknownException(message: e.toString()),
          );
        }

        return _authRepository.delete();
      },
    );
  }

  @override
  Future<Either<Exception, void>> reauthenticate() {
    return _authRepository.reauthenticate();
  }
}
