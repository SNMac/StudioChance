import 'package:fpdart/fpdart.dart';

import 'package:studio_chance/domain/entities/auth_info.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/enums/user_role.dart';

abstract interface class UserRepository {
  /// 로그인 후 호출: DB 조회 후 없으면 생성, 있으면 갱신하여 반환
  Future<Either<Exception, User>> fetchOrCreateUser(AuthInfo authInfo);

  /// 현재 로그인된 사용자 정보 반환
  /// - 로그인 상태가 아니거나 DB에 정보가 없으면 null 반환
  Future<Either<Exception, User?>> getCurrentUser();

  /// 특정 사용자 정보 반환
  /// - DB에 정보가 없으면 null 반환
  Future<Either<Exception, User?>> getUser(String uid);

  /// 사용자 프로필 정보 업데이트
  Future<Either<Exception, void>> updateUser({
    required String uid,
    String? email,
    String? nickname,
    UserRole? role,
  });

  /// 현재 기기의 FCM 토큰을 찾아 DB에서 제거 (로그아웃용)
  Future<void> removeCurrentDeviceFcmToken(String uid);

  /// 유저 데이터를 Soft Delete 처리 (탈퇴용)
  Future<void> softDeleteUser(String uid);
}
