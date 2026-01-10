// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Store _$StoreFromJson(Map<String, dynamic> json) => _Store(
  id: json['id'] as String,
  adminIds: (json['adminIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  name: json['name'] as String,
  color: json['color'] as String,
  members: (json['members'] as List<dynamic>)
      .map((e) => User.fromJson(e as Map<String, dynamic>))
      .toList(),
  priceSettings: PriceSetting.fromJson(
    json['priceSettings'] as Map<String, dynamic>,
  ),
  inviteInfo: json['inviteInfo'] == null
      ? null
      : InviteInfo.fromJson(json['inviteInfo'] as Map<String, dynamic>),
);

Map<String, dynamic> _$StoreToJson(_Store instance) => <String, dynamic>{
  'id': instance.id,
  'adminIds': instance.adminIds,
  'name': instance.name,
  'color': instance.color,
  'members': instance.members.map((e) => e.toJson()).toList(),
  'priceSettings': instance.priceSettings.toJson(),
  'inviteInfo': instance.inviteInfo?.toJson(),
};
