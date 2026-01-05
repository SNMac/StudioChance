// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PriceSetting _$PriceSettingFromJson(Map<String, dynamic> json) =>
    _PriceSetting(
      dayGroups: (json['dayGroups'] as List<dynamic>)
          .map((e) => DayGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PriceSettingToJson(_PriceSetting instance) =>
    <String, dynamic>{
      'dayGroups': instance.dayGroups.map((e) => e.toJson()).toList(),
    };
