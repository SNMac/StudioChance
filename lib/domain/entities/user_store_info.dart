import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/constants/data_constants.dart';

part 'user_store_info.freezed.dart';

@freezed
abstract class UserStoreInfo with _$UserStoreInfo {
  const UserStoreInfo._();

  const factory UserStoreInfo({
    required String id,
    required String name,
    required UserRole role,
    required StoreColor color,
    required String memo,

    /// 가입을 신청했지만 아직 관리자가 승인하지 않은 점포.
    /// 멤버가 아니라 Rules가 점포·예약 읽기를 거부하므로 구독하면 안 된다.
    @Default(false) bool isPending,

    /// 점포 삭제로 삭제 예정 점포가 된 시각(서버 시각). 점포 복구를 하면 지워진다 (ADR-0007)
    DateTime? deletedAt,
  }) = _UserStoreInfo;

  /// 삭제 예정 점포. 읽기 전용이며 예약을 추가하거나 고칠 수 없다
  bool get isScheduledForDeletion => deletedAt != null;

  /// 예약을 추가·수정·삭제할 수 있는 점포. 관리자·스태프여야 하고, 승인 대기 중이거나
  /// 삭제 예정이면 Rules가 예약 쓰기를 거부한다
  bool get canWriteReservations =>
      !isPending &&
      !isScheduledForDeletion &&
      (role == UserRole.admin || role == UserRole.staff);

  /// 점포 정보·요금·멤버를 관리할 수 있는 점포. 관리자이고 삭제 예정이 아니어야 한다.
  /// 삭제 예정 점포의 관리자는 점포 복구와 영구 삭제만 할 수 있다 (ADR-0007)
  bool get canManageStore =>
      !isPending && !isScheduledForDeletion && role == UserRole.admin;

  /// 완전히 지워지는 시각. 이 시각이 지나면 점포 복구를 할 수 없다
  DateTime? get deletionDeadline =>
      deletedAt?.add(const Duration(days: storeSoftDeleteDays));

  /// [now]에 기한이 지난 삭제 예정 점포. 복구할 수 없고 TTL이 지우기를 기다릴 뿐이다
  bool isDeletionDeadlinePassedAt(DateTime now) =>
      !(deletionDeadline?.isAfter(now) ?? true);
}
