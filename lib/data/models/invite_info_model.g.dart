// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InviteInfoModel _$InviteInfoModelFromJson(Map<String, dynamic> json) =>
    _InviteInfoModel(
      inviteCode: json['inviteCode'] as String,
      createdAt: _$JsonConverterFromJson<Timestamp, DateTime>(
        json['createdAt'],
        const TimestampConverter().fromJson,
      ),
    );

Map<String, dynamic> _$InviteInfoModelToJson(_InviteInfoModel instance) =>
    <String, dynamic>{
      'inviteCode': instance.inviteCode,
      'createdAt': ?_$JsonConverterToJson<Timestamp, DateTime>(
        instance.createdAt,
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
