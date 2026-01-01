// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  name: json['name'] as String,
  nickname: json['nickname'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  storeIds: (json['storeIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'nickname': instance.nickname,
  'role': _$UserRoleEnumMap[instance.role]!,
  'storeIds': instance.storeIds,
};

const _$UserRoleEnumMap = {
  UserRole.none: 'none',
  UserRole.admin: 'admin',
  UserRole.staff: 'staff',
  UserRole.viewer: 'viewer',
};
