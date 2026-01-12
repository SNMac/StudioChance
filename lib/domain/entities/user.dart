import 'package:freezed_annotation/freezed_annotation.dart';

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
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime lastLoginAt,
  }) = _User;

  bool get isNewUser => nickname == null;
}
