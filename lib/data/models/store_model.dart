import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/data/models/invite_info_model.dart';
import 'package:studio_chance/data/models/price_settings_model.dart';
import 'package:studio_chance/data/models/store_member_info_model.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/common/converters/timestamp_converter.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';

part 'store_model.freezed.dart';
part 'store_model.g.dart';

@freezed
abstract class StoreModel with _$StoreModel {
  const StoreModel._();

  const factory StoreModel({
    @JsonKey(includeToJson: false) required String id,
    required String name,
    required String address,
    required String memo,

    required PriceSettingsModel priceSettingsModel,
    required Map<String, StoreMemberInfoModel> memberById,
    @Default({}) Map<String, StoreMemberInfoModel> waitingMemberById,

    InviteInfoModel? inviteInfoModel,

    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,

    @JsonKey(includeIfNull: false) @TimestampConverter() DateTime? deletedAt,
    @JsonKey(includeIfNull: false) @TimestampConverter() DateTime? expiresAt,
  }) = _StoreModel;

  factory StoreModel.fromJson(Map<String, dynamic> json) =>
      _$StoreModelFromJson(json);

  factory StoreModel.fromEntity(Store entity) {
    final now = DateTime.now();
    return StoreModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      memo: entity.memo,
      priceSettingsModel: PriceSettingsModel.fromEntity(entity.priceSettings),
      memberById: {
        for (var member in entity.memberInfos)
          member.user.id: StoreMemberInfoModel(role: member.role),
      },
      waitingMemberById: {
        for (var member in entity.waitingMemberInfos)
          member.user.id: StoreMemberInfoModel(role: member.role),
      },
      inviteInfoModel: entity.inviteInfo != null
          ? InviteInfoModel.fromEntity(entity.inviteInfo!)
          : null,
      createdAt: entity.createdAt ?? now,
      updatedAt: entity.updatedAt ?? now,
    );
  }

  Store toEntity({
    required List<StoreMemberInfo> memberInfos,
    required List<StoreMemberInfo> waitingMemberInfos,
  }) {
    return Store(
      id: id,
      name: name,
      address: address,
      memo: memo,
      priceSettings: priceSettingsModel.toEntity(),
      memberInfos: memberInfos,
      waitingMemberInfos: waitingMemberInfos,
      inviteInfo: inviteInfoModel?.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
