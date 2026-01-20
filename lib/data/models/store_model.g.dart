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
  memo: json['memo'] as String,
  priceSettingsModel: PriceSettingsModel.fromJson(
    json['priceSettingsModel'] as Map<String, dynamic>,
  ),
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
);

Map<String, dynamic> _$StoreModelToJson(_StoreModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'addressDetail': instance.addressDetail,
      'addressGuide': instance.addressGuide,
      'memo': instance.memo,
      'priceSettingsModel': instance.priceSettingsModel.toJson(),
      'memberById': instance.memberById.map((k, e) => MapEntry(k, e.toJson())),
      'waitingMemberById': instance.waitingMemberById.map(
        (k, e) => MapEntry(k, e.toJson()),
      ),
      'inviteInfoModel': instance.inviteInfoModel?.toJson(),
    };
