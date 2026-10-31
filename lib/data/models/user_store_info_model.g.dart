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
      alias: json['alias'] as String?,
      isPending: json['isPending'] as bool? ?? false,
      deletedAt: _$JsonConverterFromJson<Timestamp, DateTime>(
        json['deletedAt'],
        const TimestampConverter().fromJson,
      ),
    );

Map<String, dynamic> _$UserStoreInfoModelToJson(_UserStoreInfoModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'role': _$UserRoleEnumMap[instance.role]!,
      'color': _$StoreColorEnumMap[instance.color]!,
      'memo': instance.memo,
      'alias': ?instance.alias,
      'isPending': instance.isPending,
      'deletedAt': ?_$JsonConverterToJson<Timestamp, DateTime>(
        instance.deletedAt,
        const TimestampConverter().toJson,
      ),
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

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
