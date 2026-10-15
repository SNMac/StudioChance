import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/enums/user_role.dart';

part 'user_store_info.freezed.dart';

@freezed
abstract class UserStoreInfo with _$UserStoreInfo {
  const factory UserStoreInfo({
    required String id,
    required String name,
    required UserRole role,
    required StoreColor color,
    required String memo,

    /// 가입을 신청했지만 아직 관리자가 승인하지 않은 점포.
    /// 멤버가 아니라 Rules가 점포·예약 읽기를 거부하므로 구독하면 안 된다.
    @Default(false) bool isPending,
  }) = _UserStoreInfo;
}
