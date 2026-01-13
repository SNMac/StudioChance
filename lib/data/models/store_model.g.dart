// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StoreModel _$StoreModelFromJson(Map<String, dynamic> json) => _StoreModel(
  id: json['id'] as String,
  name: json['name'] as String,
  address: json['address'] as String,
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
      'name': instance.name,
      'address': instance.address,
      'addressGuide': instance.addressGuide,
      'memo': instance.memo,
      'priceSettingsModel': instance.priceSettingsModel.toJson(),
      'memberById': instance.memberById.map((k, e) => MapEntry(k, e.toJson())),
      'waitingMemberById': instance.waitingMemberById.map(
        (k, e) => MapEntry(k, e.toJson()),
      ),
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
