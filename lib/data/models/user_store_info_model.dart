import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/user_store_info.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/enums/user_role.dart';

part 'user_store_info_model.freezed.dart';
part 'user_store_info_model.g.dart';

@freezed
abstract class UserStoreInfoModel with _$UserStoreInfoModel {
  const UserStoreInfoModel._();

  const factory UserStoreInfoModel({
    required String name,
    required StoreColor color,
    required UserRole role,
  }) = _UserStoreInfoModel;

  factory UserStoreInfoModel.fromJson(Map<String, dynamic> json) =>
      _$UserStoreInfoModelFromJson(json);

  factory UserStoreInfoModel.fromEntity(UserStoreInfo entity) {
    return UserStoreInfoModel(
      name: entity.name,
      color: entity.color,
      role: entity.role,
    );
  }

  UserStoreInfo toEntity({required String storeId}) {
    return UserStoreInfo(id: storeId, name: name, color: color, role: role);
  }
}
