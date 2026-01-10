// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PriceSettingsModel _$PriceSettingsModelFromJson(Map<String, dynamic> json) =>
    _PriceSettingsModel(
      dayGroupModels:
          (json['dayGroupModels'] as List<dynamic>?)
              ?.map((e) => DayGroupModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PriceSettingsModelToJson(_PriceSettingsModel instance) =>
    <String, dynamic>{
      'dayGroupModels': instance.dayGroupModels.map((e) => e.toJson()).toList(),
    };
