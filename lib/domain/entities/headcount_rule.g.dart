// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'headcount_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HeadcountRule _$HeadcountRuleFromJson(Map<String, dynamic> json) =>
    _HeadcountRule(
      headcountBase: (json['headcountBase'] as num).toInt(),
      headcountExtraPrice: (json['headcountExtraPrice'] as num).toInt(),
      isHeadcountHourly: json['isHeadcountHourly'] as bool,
      isHeadcountPerPerson: json['isHeadcountPerPerson'] as bool,
    );

Map<String, dynamic> _$HeadcountRuleToJson(_HeadcountRule instance) =>
    <String, dynamic>{
      'headcountBase': instance.headcountBase,
      'headcountExtraPrice': instance.headcountExtraPrice,
      'isHeadcountHourly': instance.isHeadcountHourly,
      'isHeadcountPerPerson': instance.isHeadcountPerPerson,
    };
