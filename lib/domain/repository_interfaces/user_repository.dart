import 'package:fpdart/fpdart.dart';

import 'package:studio_chance/domain/entities/auth_info.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/common/enums/store_color.dart';

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
  });

  /// 사용자의 점포 정보 수정 — 넘긴 값만 바꾼다
  /// - [alias]: 빈 문자열이면 점포 별명을 지운다
  Future<Either<Exception, void>> updateStoreInfo({
    required String uid,
    required String storeId,
    String? alias,
    StoreColor? color,
    String? memo,
  });

  /// 현재 기기의 FCM 토큰을 찾아 DB에서 제거 (로그아웃용)
  Future<void> removeCurrentDeviceFcmToken(String uid);

  /// 계정 삭제: 사용자 문서에 [nickname]만 남기고 나머지 정보와 FCM 토큰을 지운다 (ADR-0005)
  Future<Either<Exception, void>> markAccountDeleted(
    String uid, {
    required String nickname,
  });
}
