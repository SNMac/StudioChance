import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/common/enums/user_role.dart';

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

/// Firestore에 쓰는 역할 값('ADMIN' 등)
///
/// `UserRole.name`은 Dart 식별자('admin')라 `@JsonValue`를 거치는 모델 직렬화로 얻는다.
/// 점 경로 update처럼 모델 전체가 아니라 역할 값만 쓸 때 사용한다
extension UserRoleJsonValue on UserRole {
  String get jsonValue =>
      StoreMemberInfoModel(role: this).toJson()['role'] as String;
}
