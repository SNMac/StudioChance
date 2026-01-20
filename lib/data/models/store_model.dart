import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/data/models/invite_info_model.dart';
import 'package:studio_chance/data/models/price_settings_model.dart';
import 'package:studio_chance/data/models/store_member_info_model.dart';
import 'package:studio_chance/domain/entities/store.dart';
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
    required String addressDetail,
    required String addressGuide,
    required String memo,

    required PriceSettingsModel priceSettingsModel,
    required Map<String, StoreMemberInfoModel> memberById,
    @Default({}) Map<String, StoreMemberInfoModel> waitingMemberById,

    InviteInfoModel? inviteInfoModel,
  }) = _StoreModel;

  factory StoreModel.fromJson(Map<String, dynamic> json) =>
      _$StoreModelFromJson(json);

  factory StoreModel.fromEntity(Store entity) {
    return StoreModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      addressDetail: entity.addressDetail,
      addressGuide: entity.addressGuide,
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
      addressDetail: addressDetail,
      addressGuide: addressGuide,
      memo: memo,
      priceSettings: priceSettingsModel.toEntity(),
      memberInfos: memberInfos,
      waitingMemberInfos: waitingMemberInfos,
      inviteInfo: inviteInfoModel?.toEntity(),
    );
  }
}
