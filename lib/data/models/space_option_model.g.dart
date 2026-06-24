// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space_option_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SpaceOptionModel _$SpaceOptionModelFromJson(Map<String, dynamic> json) =>
    _SpaceOptionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      priceSettings: PriceSettingsModel.fromJson(
        json['priceSettings'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$SpaceOptionModelToJson(_SpaceOptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'priceSettings': instance.priceSettings.toJson(),
    };
