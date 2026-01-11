import 'package:fpdart/fpdart.dart';

import 'package:studio_chance/domain/entities/auth_info.dart';

abstract interface class AuthRepository {
  /// 인증 상태 변경 `Stream`
  Stream<AuthInfo?> authStateChanges();

  /// Google 로그인
  Future<Either<Exception, AuthInfo>> signInWithGoogle();

  /// Apple 로그인
  Future<Either<Exception, AuthInfo>> signInWithApple();

  /// 로그아웃
  Future<void> signOut();

  /// 회원 탈퇴
  Future<Either<Exception, void>> delete();

  /// 재인증
  Future<Either<Exception, void>> reauthenticate();
}
