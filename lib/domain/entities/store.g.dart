// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Store _$StoreFromJson(Map<String, dynamic> json) => _Store(
  id: json['id'] as String,
  ownerId: json['ownerId'] as String,
  name: json['name'] as String,
  color: json['color'] as String,
  members: (json['members'] as List<dynamic>)
      .map((e) => User.fromJson(e as Map<String, dynamic>))
      .toList(),
  priceSettings: (json['priceSettings'] as List<dynamic>)
      .map((e) => DayGroup.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$StoreToJson(_Store instance) => <String, dynamic>{
  'id': instance.id,
  'ownerId': instance.ownerId,
  'name': instance.name,
  'color': instance.color,
  'members': instance.members,
  'priceSettings': instance.priceSettings,
};
