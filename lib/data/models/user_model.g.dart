// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  name: json['name'] as String,
  fcmTokens:
      (json['fcmTokens'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  nickname: json['nickname'] as String?,
  role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.none,
  storeIds:
      (json['storeIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'fcmTokens': instance.fcmTokens,
      'nickname': instance.nickname,
      'role': _$UserRoleEnumMap[instance.role]!,
      'storeIds': instance.storeIds,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.none: 'none',
  UserRole.admin: 'admin',
  UserRole.staff: 'staff',
  UserRole.viewer: 'viewer',
};
