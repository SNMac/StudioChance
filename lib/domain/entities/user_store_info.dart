import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studio_chance/domain/enums/store_color.dart';

import 'package:studio_chance/domain/enums/user_role.dart';

part 'user_store_info.freezed.dart';

@freezed
abstract class UserStoreInfo with _$UserStoreInfo {
  const factory UserStoreInfo({
    required String id,
    required String name,
    required StoreColor color,
    required UserRole role,
  }) = _UserStoreInfo;
}
