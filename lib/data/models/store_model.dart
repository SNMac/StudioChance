import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/data/models/invite_info_model.dart';
import 'package:studio_chance/data/models/space_option_model.dart';
import 'package:studio_chance/data/models/store_member_info_model.dart';
import 'package:studio_chance/domain/entities/space_option.dart';
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

    @Default([]) List<SpaceOptionModel> spaceOptions,
    required Map<String, StoreMemberInfoModel> memberById,
    @Default({}) Map<String, StoreMemberInfoModel> waitingMemberById,

    InviteInfoModel? inviteInfoModel,
    String? bankName,
    String? bankAccountNumber,
    String? bankAccountHolder,
    int? paymentDeadlineMinutes,
    String? infoNotes,
    String? cautionNotes,
  }) = _StoreModel;

  factory StoreModel.fromJson(Map<String, dynamic> json) =>
      _$StoreModelFromJson(json);

  /// 점포 수정 가능 필드만 반환 (memberById, waitingMemberById, inviteInfoModel 제외)
  Map<String, dynamic> toEditableJson() => {
    'name': name,
    'address': address,
    'addressDetail': addressDetail,
    'addressGuide': addressGuide,
    'spaceOptions': spaceOptions.map((s) => s.toJson()).toList(),
    'bankName': bankName,
    'bankAccountNumber': bankAccountNumber,
    'bankAccountHolder': bankAccountHolder,
    'paymentDeadlineMinutes': paymentDeadlineMinutes,
    'infoNotes': infoNotes,
    'cautionNotes': cautionNotes,
  };

  factory StoreModel.fromEntity(Store entity) {
    return StoreModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      addressDetail: entity.addressDetail,
      addressGuide: entity.addressGuide,
      spaceOptions: entity.spaceOptions
          .map((s) => SpaceOptionModel.fromEntity(s))
          .toList(),
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
      bankName: entity.bankName,
      bankAccountNumber: entity.bankAccountNumber,
      bankAccountHolder: entity.bankAccountHolder,
      paymentDeadlineMinutes: entity.paymentDeadlineMinutes,
      infoNotes: entity.infoNotes,
      cautionNotes: entity.cautionNotes,
    );
  }

  Store toEntity({
    required List<StoreMemberInfo> memberInfos,
    required List<StoreMemberInfo> waitingMemberInfos,
  }) {
    final List<SpaceOption> entitySpaceOptions = spaceOptions.isEmpty
        ? [SpaceOption.empty()]
        : spaceOptions.map((s) => s.toEntity()).toList();

    return Store(
      id: id,
      name: name,
      address: address,
      addressDetail: addressDetail,
      addressGuide: addressGuide,
      spaceOptions: entitySpaceOptions,
      memberInfos: memberInfos,
      waitingMemberInfos: waitingMemberInfos,
      inviteInfo: inviteInfoModel?.toEntity(),
      bankName: bankName,
      bankAccountNumber: bankAccountNumber,
      bankAccountHolder: bankAccountHolder,
      paymentDeadlineMinutes: paymentDeadlineMinutes,
      infoNotes: infoNotes,
      cautionNotes: cautionNotes,
    );
  }
}
