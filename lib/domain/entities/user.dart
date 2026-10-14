import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/domain/entities/user_store_info.dart';

part 'user.freezed.dart';

@freezed
abstract class User with _$User {
  const User._();

  const factory User({
    required String id,
    required String name,
    required String email,
    required String? nickname,
    required List<String> authProviders,
    required List<UserStoreInfo> storeInfos,
  }) = _User;

  bool get isNewUser => nickname == null;

  /// [storeId] 점포에서의 내 정보(표시 이름·역할·색상·메모). 소속되지 않았으면 null
  UserStoreInfo? storeInfoOf(String storeId) =>
      storeInfos.where((info) => info.id == storeId).firstOrNull;

  /// [storeId] 점포에서의 내 역할. 소속되지 않았으면 null
  UserRole? roleIn(String storeId) => storeInfoOf(storeId)?.role;
}
