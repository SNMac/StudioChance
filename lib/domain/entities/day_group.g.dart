// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DayGroup _$DayGroupFromJson(Map<String, dynamic> json) => _DayGroup(
  days: (json['days'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
  headcountRule: HeadcountRule.fromJson(
    json['headcountRule'] as Map<String, dynamic>,
  ),
  timeSlots: (json['timeSlots'] as List<dynamic>)
      .map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DayGroupToJson(_DayGroup instance) => <String, dynamic>{
  'days': instance.days,
  'headcountRule': instance.headcountRule.toJson(),
  'timeSlots': instance.timeSlots.map((e) => e.toJson()).toList(),
};
