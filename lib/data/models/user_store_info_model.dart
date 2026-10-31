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
    /// 점포 이름 캐시. 점포 이름이 바뀌면 `StoreDataSource.updateStore`가
    /// 멤버 모두에게 동기화한다. 멤버가 붙이는 점포 별명은 [alias]에 따로 둔다
    required String name,
    required UserRole role,
    required StoreColor color,
    required String memo,

    /// 점포 별명. 없으면 필드를 두지 않는다
    @JsonKey(includeIfNull: false) String? alias,

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
      alias: entity.alias,
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
      alias: alias,
      role: role,
      color: color,
      memo: memo,
      isPending: isPending,
      deletedAt: deletedAt,
    );
  }
}
