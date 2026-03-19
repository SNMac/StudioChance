import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/enums/user_role.dart';

part 'store_member_info_model.freezed.dart';
part 'store_member_info_model.g.dart';

@freezed
abstract class StoreMemberInfoModel with _$StoreMemberInfoModel {
  const StoreMemberInfoModel._();

  const factory StoreMemberInfoModel({required UserRole role}) =
      _StoreMemberInfoModel;

  factory StoreMemberInfoModel.fromJson(Map<String, dynamic> json) =>
      _$StoreMemberInfoModelFromJson(json);

  factory StoreMemberInfoModel.fromEntity(StoreMemberInfo entity) {
    return StoreMemberInfoModel(role: entity.role);
  }

  StoreMemberInfo toEntity({required User user}) {
    return StoreMemberInfo(user: user, role: role);
  }
}
