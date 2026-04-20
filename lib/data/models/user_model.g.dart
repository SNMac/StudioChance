// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  nickname: json['nickname'] as String?,
  authProviders:
      (json['authProviders'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  fcmTokens:
      (json['fcmTokens'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  storeById:
      (json['storeById'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, UserStoreInfoModel.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'name': instance.name,
      'nickname': instance.nickname,
      'authProviders': instance.authProviders,
      'storeById': instance.storeById.map((k, e) => MapEntry(k, e.toJson())),
    };
