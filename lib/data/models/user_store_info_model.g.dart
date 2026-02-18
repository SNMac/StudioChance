// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_store_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserStoreInfoModel _$UserStoreInfoModelFromJson(Map<String, dynamic> json) =>
    _UserStoreInfoModel(
      name: json['name'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      color: $enumDecode(_$StoreColorEnumMap, json['color']),
      memo: json['memo'] as String,
    );

Map<String, dynamic> _$UserStoreInfoModelToJson(_UserStoreInfoModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'role': _$UserRoleEnumMap[instance.role]!,
      'color': _$StoreColorEnumMap[instance.color]!,
      'memo': instance.memo,
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 'ADMIN',
  UserRole.staff: 'STAFF',
  UserRole.viewer: 'VIEWER',
  UserRole.none: 'NONE',
};

const _$StoreColorEnumMap = {
  StoreColor.red: 'RED',
  StoreColor.orange: 'ORANGE',
  StoreColor.yellow: 'YELLOW',
  StoreColor.green: 'GREEN',
  StoreColor.blue: 'BLUE',
  StoreColor.indigo: 'INDIGO',
  StoreColor.purple: 'PURPLE',
};
