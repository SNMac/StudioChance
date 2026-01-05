// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'headcount_rule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HeadcountRuleModel _$HeadcountRuleModelFromJson(Map<String, dynamic> json) =>
    _HeadcountRuleModel(
      headcountBase: (json['headcountBase'] as num).toInt(),
      headcountExtraPrice: (json['headcountExtraPrice'] as num).toInt(),
      isHeadcountHourly: json['isHeadcountHourly'] as bool,
      isHeadcountPerPerson: json['isHeadcountPerPerson'] as bool,
    );

Map<String, dynamic> _$HeadcountRuleModelToJson(_HeadcountRuleModel instance) =>
    <String, dynamic>{
      'headcountBase': instance.headcountBase,
      'headcountExtraPrice': instance.headcountExtraPrice,
      'isHeadcountHourly': instance.isHeadcountHourly,
      'isHeadcountPerPerson': instance.isHeadcountPerPerson,
    };
