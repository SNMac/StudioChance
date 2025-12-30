import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/domain/entities/store.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String nickname,
    required UserRole role,
    required List<Store> stores,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
