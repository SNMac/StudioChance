// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  nickname: json['nickname'] as String? ?? '',
  authProviders:
      (json['authProviders'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  fcmTokens:
      (json['fcmTokens'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.none,
  storeIds:
      (json['storeIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  updatedAt: const TimestampConverter().fromJson(
    json['updatedAt'] as Timestamp,
  ),
  lastLoginAt: const TimestampConverter().fromJson(
    json['lastLoginAt'] as Timestamp,
  ),
  deletedAt: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['deletedAt'],
    const TimestampConverter().fromJson,
  ),
  expiresAt: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['expiresAt'],
    const TimestampConverter().fromJson,
  ),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'name': instance.name,
      'nickname': instance.nickname,
      'authProviders': instance.authProviders,
      'fcmTokens': instance.fcmTokens,
      'role': _$UserRoleEnumMap[instance.role]!,
      'storeIds': instance.storeIds,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'lastLoginAt': const TimestampConverter().toJson(instance.lastLoginAt),
      'deletedAt': ?_$JsonConverterToJson<Timestamp, DateTime>(
        instance.deletedAt,
        const TimestampConverter().toJson,
      ),
      'expiresAt': ?_$JsonConverterToJson<Timestamp, DateTime>(
        instance.expiresAt,
        const TimestampConverter().toJson,
      ),
    };

const _$UserRoleEnumMap = {
  UserRole.none: 'none',
  UserRole.admin: 'admin',
  UserRole.staff: 'staff',
  UserRole.viewer: 'viewer',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
