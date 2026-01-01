import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studio_chance/common/errors/failures.dart';
import 'package:studio_chance/domain/entities/user.dart';

abstract interface class AuthRepository {
  /// Google 로그인
  Future<Either<Failure, User>> signInWithGoogle();
  /// Apple 로그인
  Future<Either<Failure, User>> signInWithApple();
  /// 로그아웃
  Future<void> signOut();
  /// 회원 탈퇴
  Future<Either<Failure, void>> delete();
  /// 재인증
  Future<Either<Failure, void>> reauthenticate();
  /// 현재 기기의 FCM 토큰을 서버에 추가
  Future<void> registerFcmToken();
  /// 무효화된 FCM 토큰을 삭제하고 새로운 FCM 토큰으로 교체
  Future<void> replaceFcmToken({required String oldToken, required String newToken});
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('Data 계층에서 override 필요');
});