import 'package:freezed_annotation/freezed_annotation.dart';

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
    @Default({}) Map<String, UserStoreInfoModel> storeById,
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
    );
  }
}
