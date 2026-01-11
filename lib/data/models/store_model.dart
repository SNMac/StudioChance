import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/data/models/invite_info_model.dart';
import 'package:studio_chance/data/models/price_settings_model.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/common/converters/timestamp_converter.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/enums/store_color.dart';

part 'store_model.freezed.dart';
part 'store_model.g.dart';

@freezed
abstract class StoreModel with _$StoreModel {
  const StoreModel._();

  const factory StoreModel({
    @JsonKey(includeToJson: false) required String id,
    required String name,
    @JsonKey(unknownEnumValue: StoreColor.red) required StoreColor color,
    required String address,
    required String memo,

    required PriceSettingsModel priceSettingsModel,
    required Map<String, String> memberIds,
    @Default({}) Map<String, String> waitingMemberIds,

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
      color: entity.color,
      address: entity.address,
      memo: entity.memo,
      priceSettingsModel: PriceSettingsModel.fromEntity(entity.priceSettings),
      memberIds: {
        for (var member in entity.members) member.id: member.role.name,
      },
      waitingMemberIds: {
        for (var m in entity.waitingMembers) m.id: m.role.name,
      },
      inviteInfoModel: entity.inviteInfo != null
          ? InviteInfoModel.fromEntity(entity.inviteInfo!)
          : null,
      createdAt: entity.createdAt ?? now,
      updatedAt: entity.updatedAt ?? now,
    );
  }

  Store toEntity({
    required List<User> members,
    required List<User> waitingMembers,
  }) {
    return Store(
      id: id,
      name: name,
      color: color,
      address: address,
      memo: memo,
      priceSettings: priceSettingsModel.toEntity(),
      members: members,
      waitingMembers: waitingMembers,
      inviteInfo: inviteInfoModel?.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
