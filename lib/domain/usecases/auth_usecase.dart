import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:studio_chance/common/errors/failures.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/repository_interfaces/auth_repository.dart';

final authUseCaseProvider = Provider<AuthUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthUseCase(repository);
});

// UseCase 클래스 정의
class AuthUseCase {
  final AuthRepository _repository;

  const AuthUseCase(this._repository);

  /// Google 로그인
  Future<Either<Failure, User>> signInWithGoogle() {
    return _repository.signInWithGoogle();
  }

  /// Apple 로그인
  Future<Either<Failure, User>> signInWithApple() {
    return _repository.signInWithApple();
  }

  /// 로그아웃
  Future<void> signOut() {
    return _repository.signOut();
  }

  /// 회원 탈퇴
  Future<Either<Failure, void>> deleteAccount() {
    return _repository.delete();
  }

  /// 재인증 (재인증 필요 오류 발생 시)
  Future<Either<Failure, void>> reauthenticate() {
    return _repository.reauthenticate();
  }

  /// FCM 토큰 동기화
  Future<void> syncFcmToken() {
    return _repository.syncFcmToken();
  }
}
