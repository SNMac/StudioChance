import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/enums/user_role.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const User._();

  const factory User({
    required String id,
    required String name,
    required String email,
    String? nickname,
    required List<String> authProviders,
    required UserRole role,
    required List<String> storeIds,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  bool get isNewUser => nickname == null;
}
