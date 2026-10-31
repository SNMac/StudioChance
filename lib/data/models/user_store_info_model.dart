import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/common/converters/timestamp_converter.dart';
import 'package:studio_chance/domain/entities/user_store_info.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/enums/user_role.dart';

part 'user_store_info_model.freezed.dart';
part 'user_store_info_model.g.dart';

@freezed
abstract class UserStoreInfoModel with _$UserStoreInfoModel {
  const UserStoreInfoModel._();

  const factory UserStoreInfoModel({
    required String name,
    required UserRole role,
    required StoreColor color,
    required String memo,

    /// 승인 전이면 true. 승인할 때 필드를 지우므로 없으면 승인된 점포다.
    @Default(false) bool isPending,

    /// 점포가 삭제 예정이 된 시각. 점포 삭제·복구가 멤버마다 쓰고 지운다 (ADR-0007)
    @JsonKey(includeIfNull: false) @TimestampConverter() DateTime? deletedAt,
  }) = _UserStoreInfoModel;

  factory UserStoreInfoModel.fromJson(Map<String, dynamic> json) =>
      _$UserStoreInfoModelFromJson(json);

  factory UserStoreInfoModel.fromEntity(UserStoreInfo entity) {
    return UserStoreInfoModel(
      name: entity.name,
      role: entity.role,
      color: entity.color,
      memo: entity.memo,
      isPending: entity.isPending,
      deletedAt: entity.deletedAt,
    );
  }

  UserStoreInfo toEntity({required String storeId}) {
    return UserStoreInfo(
      id: storeId,
      name: name,
      role: role,
      color: color,
      memo: memo,
      isPending: isPending,
      deletedAt: deletedAt,
    );
  }
}
