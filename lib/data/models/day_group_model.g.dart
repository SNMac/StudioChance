// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DayGroupModel _$DayGroupModelFromJson(Map<String, dynamic> json) =>
    _DayGroupModel(
      days:
          (json['days'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      headcountRule: HeadcountRuleModel.fromJson(
        json['headcountRule'] as Map<String, dynamic>,
      ),
      timeSlots:
          (json['timeSlots'] as List<dynamic>?)
              ?.map((e) => TimeSlotModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DayGroupModelToJson(_DayGroupModel instance) =>
    <String, dynamic>{
      'days': instance.days,
      'headcountRule': instance.headcountRule.toJson(),
      'timeSlots': instance.timeSlots.map((e) => e.toJson()).toList(),
    };
