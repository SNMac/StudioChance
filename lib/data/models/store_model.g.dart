// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StoreModel _$StoreModelFromJson(Map<String, dynamic> json) => _StoreModel(
  id: json['id'] as String,
  name: json['name'] as String,
  address: json['address'] as String,
  addressDetail: json['addressDetail'] as String,
  addressGuide: json['addressGuide'] as String,
  spaceOptions:
      (json['spaceOptions'] as List<dynamic>?)
          ?.map((e) => SpaceOptionModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  memberById: (json['memberById'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, StoreMemberInfoModel.fromJson(e as Map<String, dynamic>)),
  ),
  waitingMemberById:
      (json['waitingMemberById'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          StoreMemberInfoModel.fromJson(e as Map<String, dynamic>),
        ),
      ) ??
      const {},
  inviteInfoModel: json['inviteInfoModel'] == null
      ? null
      : InviteInfoModel.fromJson(
          json['inviteInfoModel'] as Map<String, dynamic>,
        ),
  bankName: json['bankName'] as String?,
  bankAccountNumber: json['bankAccountNumber'] as String?,
  bankAccountHolder: json['bankAccountHolder'] as String?,
  paymentDeadlineMinutes: (json['paymentDeadlineMinutes'] as num?)?.toInt(),
  infoNotes: json['infoNotes'] as String?,
  cautionNotes: json['cautionNotes'] as String?,
);

Map<String, dynamic> _$StoreModelToJson(_StoreModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'addressDetail': instance.addressDetail,
      'addressGuide': instance.addressGuide,
      'spaceOptions': instance.spaceOptions.map((e) => e.toJson()).toList(),
      'memberById': instance.memberById.map((k, e) => MapEntry(k, e.toJson())),
      'waitingMemberById': instance.waitingMemberById.map(
        (k, e) => MapEntry(k, e.toJson()),
      ),
      'inviteInfoModel': instance.inviteInfoModel?.toJson(),
      'bankName': instance.bankName,
      'bankAccountNumber': instance.bankAccountNumber,
      'bankAccountHolder': instance.bankAccountHolder,
      'paymentDeadlineMinutes': instance.paymentDeadlineMinutes,
      'infoNotes': instance.infoNotes,
      'cautionNotes': instance.cautionNotes,
    };
