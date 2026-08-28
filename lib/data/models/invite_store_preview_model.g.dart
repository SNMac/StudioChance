// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_store_preview_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InviteStorePreviewModel _$InviteStorePreviewModelFromJson(
  Map<String, dynamic> json,
) => _InviteStorePreviewModel(
  storeId: json['storeId'] as String,
  storeName: json['storeName'] as String,
  address: json['address'] as String,
  addressDetail: json['addressDetail'] as String,
  adminName: json['adminName'] as String,
);

Map<String, dynamic> _$InviteStorePreviewModelToJson(
  _InviteStorePreviewModel instance,
) => <String, dynamic>{
  'storeId': instance.storeId,
  'storeName': instance.storeName,
  'address': instance.address,
  'addressDetail': instance.addressDetail,
  'adminName': instance.adminName,
};
