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

  /// 계정 삭제 준비: 재인증 후 Apple이 연동되어 있으면 Apple 토큰을 revoke한다
  /// - 계정 삭제의 어떤 쓰기보다 먼저 호출한다. left이면 아무것도 바뀌지 않은 상태다
  /// - 재인증 실패, revoke 중 취소·네트워크 오류는 left
  /// - 그 밖의 revoke 실패는 기록만 하고 right — 우리 쪽 설정 오류로 계정 삭제가
  ///   막히지 않게 한다 (ADR-0005)
  Future<Either<Exception, void>> prepareDeletion();

  /// 계정 삭제의 마지막 단계: Firebase Auth 계정을 지운다 ([prepareDeletion] 이후)
  Future<Either<Exception, void>> delete();

  /// 재인증
  Future<Either<Exception, void>> reauthenticate();
}
