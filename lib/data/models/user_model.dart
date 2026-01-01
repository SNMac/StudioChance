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
    @JsonKey(includeToJson: false)
    required String id,
    required String name,
    @Default('') String nickname,
    @Default([]) List<String> authProviders,
    @Default([]) List<String> fcmTokens,
    @Default(UserRole.none) UserRole role,
    @Default([]) List<String> storeIds,

    // DataSource에서 serverTimestamp로 저장되지만, 우선 Datetime 입력
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    @TimestampConverter() required DateTime lastLoginAt,

    @JsonKey(includeIfNull: false)
    @TimestampConverter() DateTime? deletedAt,
    @JsonKey(includeIfNull: false)
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
      authProviders: authProviders,
      role: role,
      storeIds: storeIds,
    );
  }
}
