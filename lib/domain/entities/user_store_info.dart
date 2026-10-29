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

  /// 완전히 지워지는 시각. 이 시각이 지나면 점포 복구를 할 수 없다
  DateTime? get deletionDeadline =>
      deletedAt?.add(const Duration(days: storeSoftDeleteDays));
}
