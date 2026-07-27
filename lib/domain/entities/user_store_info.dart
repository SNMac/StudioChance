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
  }) = _UserStoreInfo;
}
