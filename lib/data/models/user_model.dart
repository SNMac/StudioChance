import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/common/converters/timestamp_converter.dart';
import 'package:studio_chance/data/models/user_store_info_model.dart';
import 'package:studio_chance/domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    @JsonKey(includeToJson: false) required String id,
    required String email,
    required String name,
    String? nickname,
    @Default([]) List<String> authProviders,
    @Default([]) List<String> fcmTokens,
    @Default({}) Map<String, UserStoreInfoModel> storeById,

    // DataSource에서 serverTimestamp로 저장되지만, 우선 Datetime 입력
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    @TimestampConverter() required DateTime lastLoginAt,

    @JsonKey(includeIfNull: false) @TimestampConverter() DateTime? deletedAt,
    @JsonKey(includeIfNull: false) @TimestampConverter() DateTime? expiresAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      nickname: entity.nickname,
      authProviders: entity.authProviders,
      storeById: {
        for (var info in entity.storeInfos)
          info.id: UserStoreInfoModel.fromEntity(info),
      },
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastLoginAt: entity.lastLoginAt,
    );
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      nickname: nickname,
      authProviders: authProviders,
      storeInfos: storeById.entries
          .map((entry) => entry.value.toEntity(storeId: entry.key))
          .toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLoginAt: lastLoginAt,
    );
  }
}
