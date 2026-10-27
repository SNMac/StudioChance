import 'package:fpdart/fpdart.dart';

import 'package:studio_chance/domain/entities/invite_info.dart';
import 'package:studio_chance/domain/entities/invite_store_preview.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/store_membership.dart';
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

  /// 점포 멤버 구성 조회 (멤버의 사용자 문서는 읽지 않는다). 없거나 삭제됐으면 null
  Future<Either<Exception, StoreMembership?>> getMembership(String storeId);

  /// 점포 정보 수정
  /// - [original]: 수정 폼을 연 시점의 점포. 그 뒤 다른 관리자가 설정을 먼저 저장했으면
  ///   `StoreUpdateConflictException`으로 실패하고 쓰지 않는다 (D13)
  Future<Either<Exception, void>> updateStore({
    required Store original,
    required Store store,
    required String uid,
    required StoreColor color,
    required String memo,
  });

  /// 점포 삭제 (Soft Delete)
  /// - [expireImmediately]: 복구 여유 기간 없이 바로 만료시킨다 (계정 삭제용)
  Future<Either<Exception, void>> softDeleteStore(
    String storeId, {
    bool expireImmediately = false,
  });

  /// 초대 코드 발급/재발급. 유효한 코드가 남아 있으면 발급은 그 코드를 돌려준다
  Future<Either<Exception, InviteInfo>> createInviteCode(
    String storeId, {
    bool forceRegenerate = false,
  });

  /// 서버 시각에서 기기 시각을 뺀 값. 초대 코드의 남은 유효 시간 표시 보정용
  Future<Either<Exception, Duration>> getServerClockOffset();

  /// 초대 코드로 가입 전 표시 정보를 조회한다. 코드가 없으면 `right(null)`.
  Future<Either<Exception, InviteStorePreview?>> getStoreByInviteCode(
    String inviteCode,
  );

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

  /// 멤버 제거 (승인 대기자 거절 / 기존 멤버 추방)
  /// - `memberById`, `waitingMemberById`, `users/{uid}.storeById`에서 모두 제거된다.
  Future<Either<Exception, void>> removeMember({
    required String storeId,
    required String uid,
  });

  /// 멤버 권한 변경
  Future<Either<Exception, void>> updateMemberRole({
    required String storeId,
    required String uid,
    required UserRole newRole,
  });

  /// 관리자 위임 — [fromUid]를 [previousAdminRole]로, [toUid]를 관리자로 한 번에 바꾼다
  /// - 트랜잭션에서 [fromUid]가 아직 관리자인지(`StorePermissionDeniedException`),
  ///   [toUid]가 아직 스태프·뷰어인지(`StoreDelegationTargetInvalidException`) 확인한다
  Future<Either<Exception, void>> delegateAdmin({
    required String storeId,
    required String fromUid,
    required String toUid,
    required UserRole previousAdminRole,
  });
}
