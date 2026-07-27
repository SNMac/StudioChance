import 'package:fpdart/fpdart.dart';

import 'package:studio_chance/domain/entities/invite_info.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/enums/user_role.dart';

abstract interface class StoreRepository {
  /// 점포 생성
  Future<Either<Exception, Store>> createStore({
    required Store store,
    required StoreColor color,
    required String memo,
  });

  /// 점포 조회
  /// - ID로 조회. 없으면 null 반환
  Future<Either<Exception, Store?>> getStore(String storeId);

  /// 점포 정보 수정
  Future<Either<Exception, void>> updateStore({
    required Store store,
    required String uid,
    required StoreColor color,
    required String memo,
  });

  /// 점포 삭제 (Soft Delete)
  Future<Either<Exception, void>> softDeleteStore(String storeId);

  /// 초대 코드 생성/재발급
  Future<Either<Exception, InviteInfo>> createInviteCode(
    String storeId, {
    bool forceRegenerate = false,
  });

  /// 초대 코드로 점포 조회
  /// - 유효성 검증된 점포 반환
  Future<Either<Exception, Store?>> getStoreByInviteCode(String inviteCode);

  /// 가입 신청 (대기 명단 추가 + 사용자 점포 정보 저장)
  Future<Either<Exception, void>> requestJoinStore({
    required String storeId,
    required String uid,
    required UserRole role,
    required StoreColor color,
    required String storeAlias,
    required String memo,
  });

  /// 멤버 승인
  Future<Either<Exception, void>> approveMember({
    required String storeId,
    required String uid,
    required UserRole role,
  });

  /// 멤버 권한 변경
  Future<Either<Exception, void>> updateMemberRole({
    required String storeId,
    required String uid,
    required UserRole newRole,
  });
}
