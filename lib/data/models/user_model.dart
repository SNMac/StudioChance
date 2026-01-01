import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/common/converters/timestamp_converter.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    @Default('') String nickname,
    @Default([]) List<String> fcmTokens,
    @Default(UserRole.none) UserRole role,
    @Default([]) List<String> storeIds,

    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    @TimestampConverter() required DateTime lastLoginAt,
    @TimestampConverter() DateTime? deletedAt,
    @TimestampConverter() DateTime? expiresAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

extension UserModelExtension on UserModel {
  User toEntity() {
    return User(
      id: id,
      name: name,
      nickname: nickname,
      role: role,
      storeIds: storeIds,
    );
  }
}
