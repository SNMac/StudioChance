// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_member_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StoreMemberInfoModel _$StoreMemberInfoModelFromJson(
  Map<String, dynamic> json,
) => _StoreMemberInfoModel(role: $enumDecode(_$UserRoleEnumMap, json['role']));

Map<String, dynamic> _$StoreMemberInfoModelToJson(
  _StoreMemberInfoModel instance,
) => <String, dynamic>{'role': _$UserRoleEnumMap[instance.role]!};

const _$UserRoleEnumMap = {
  UserRole.admin: 'ADMIN',
  UserRole.staff: 'STAFF',
  UserRole.viewer: 'VIEWER',
  UserRole.none: 'NONE',
};
