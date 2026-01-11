import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studio_chance/domain/entities/store.dart';

import 'package:studio_chance/domain/enums/user_role.dart';

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
    required UserRole role,
    required List<Store> stores,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime lastLoginAt,
  }) = _User;

  bool get isNewUser => nickname == null;
}
