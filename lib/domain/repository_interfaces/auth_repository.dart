import 'package:fpdart/fpdart.dart';

import 'package:studio_chance/domain/entities/user.dart';

abstract interface class AuthRepository {
  /// 인증 상태 변경 `Stream`
  Stream<User?> authStateChanges();

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
