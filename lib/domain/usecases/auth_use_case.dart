import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/repository_interfaces/auth_repository.dart';
import 'package:studio_chance/data/repositories/auth_repository_impl.dart';

part 'auth_use_case.g.dart';

abstract interface class AuthUseCase {
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

  /// 현재 기기의 FCM 토큰을 서버에 추가
  Future<void> registerFcmToken();

  /// 무효화된 FCM 토큰을 삭제하고 새로운 FCM 토큰으로 교체
  Future<void> replaceFcmToken({
    required String oldToken,
    required String newToken,
  });
}

class AuthUseCaseImpl implements AuthUseCase {
  final AuthRepository _repository;

  const AuthUseCaseImpl(this._repository);

  @override
  Future<Either<Exception, User>> signInWithGoogle() {
    return _repository.signInWithGoogle();
  }

  @override
  Future<Either<Exception, User>> signInWithApple() {
    return _repository.signInWithApple();
  }

  @override
  Future<void> signOut() {
    return _repository.signOut();
  }

  @override
  Future<Either<Exception, void>> delete() {
    return _repository.delete();
  }

  @override
  Future<Either<Exception, void>> reauthenticate() {
    return _repository.reauthenticate();
  }

  @override
  Future<void> registerFcmToken() {
    return _repository.registerFcmToken();
  }

  @override
  Future<void> replaceFcmToken({
    required String oldToken,
    required String newToken,
  }) {
    return _repository.replaceFcmToken(oldToken: oldToken, newToken: newToken);
  }
}

@riverpod
AuthUseCase authUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);

  return AuthUseCaseImpl(repository);
}
