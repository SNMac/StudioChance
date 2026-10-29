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

    /// 문서의 `deletedAt`에서 정해지므로 JSON으로 읽고 쓰지 않는다 ([UserModel.deleted])
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(false)
    bool isDeleted,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// 삭제된 계정. 문서에는 닉네임만 남는다 (ADR-0005)
  /// - 문서 자체가 없을 때도 쓴다 (닉네임 null)
  factory UserModel.deleted({required String id, String? nickname}) =>
      UserModel(
        id: id,
        email: '',
        name: '',
        nickname: nickname,
        isDeleted: true,
      );

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
      isDeleted: entity.isDeleted,
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
      isDeleted: isDeleted,
    );
  }
}
