// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StoreModel _$StoreModelFromJson(Map<String, dynamic> json) => _StoreModel(
  id: json['id'] as String,
  adminIds:
      (json['adminIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  name: json['name'] as String,
  memberIds: Map<String, String>.from(json['memberIds'] as Map),
  address: json['address'] as String,
  memo: json['memo'] as String,
  color: json['color'] as String,
  priceSettingsModel: PriceSettingsModel.fromJson(
    json['priceSettingsModel'] as Map<String, dynamic>,
  ),
  inviteInfoModel: json['inviteInfoModel'] == null
      ? null
      : InviteInfoModel.fromJson(
          json['inviteInfoModel'] as Map<String, dynamic>,
        ),
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  updatedAt: const TimestampConverter().fromJson(
    json['updatedAt'] as Timestamp,
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

Map<String, dynamic> _$StoreModelToJson(_StoreModel instance) =>
    <String, dynamic>{
      'adminIds': instance.adminIds,
      'name': instance.name,
      'memberIds': instance.memberIds,
      'address': instance.address,
      'memo': instance.memo,
      'color': instance.color,
      'priceSettingsModel': instance.priceSettingsModel.toJson(),
      'inviteInfoModel': instance.inviteInfoModel?.toJson(),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'deletedAt': ?_$JsonConverterToJson<Timestamp, DateTime>(
        instance.deletedAt,
        const TimestampConverter().toJson,
      ),
      'expiresAt': ?_$JsonConverterToJson<Timestamp, DateTime>(
        instance.expiresAt,
        const TimestampConverter().toJson,
      ),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
