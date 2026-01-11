// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InviteInfoModel _$InviteInfoModelFromJson(Map<String, dynamic> json) =>
    _InviteInfoModel(
      inviteCode: json['inviteCode'] as String,
      createdAt: const TimestampConverter().fromJson(
        json['createdAt'] as Timestamp,
      ),
    );

Map<String, dynamic> _$InviteInfoModelToJson(_InviteInfoModel instance) =>
    <String, dynamic>{
      'inviteCode': instance.inviteCode,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
