import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/common/enums/user_role.dart';

part 'store_member_info.freezed.dart';

@freezed
abstract class StoreMemberInfo with _$StoreMemberInfo {
  const factory StoreMemberInfo({
    required User user,
    required UserRole role,
  }) = _StoreMemberInfo;
}
