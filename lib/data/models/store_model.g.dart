// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StoreModel _$StoreModelFromJson(Map<String, dynamic> json) => _StoreModel(
  id: json['id'] as String,
  name: json['name'] as String,
  color: $enumDecode(
    _$StoreColorEnumMap,
    json['color'],
    unknownValue: StoreColor.red,
  ),
  address: json['address'] as String,
  memo: json['memo'] as String,
  priceSettingsModel: PriceSettingsModel.fromJson(
    json['priceSettingsModel'] as Map<String, dynamic>,
  ),
  memberIds: Map<String, String>.from(json['memberIds'] as Map),
  waitingMemberIds:
      (json['waitingMemberIds'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
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
      'color': _$StoreColorEnumMap[instance.color]!,
      'address': instance.address,
      'memo': instance.memo,
      'priceSettingsModel': instance.priceSettingsModel.toJson(),
      'memberIds': instance.memberIds,
      'waitingMemberIds': instance.waitingMemberIds,
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
