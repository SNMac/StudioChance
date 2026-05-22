// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DayGroupModel _$DayGroupModelFromJson(Map<String, dynamic> json) =>
    _DayGroupModel(
      days:
          (json['days'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$WeekdayEnumMap, e))
              .toList() ??
          const [],
      headcountRuleModel: HeadcountRuleModel.fromJson(
        json['headcountRuleModel'] as Map<String, dynamic>,
      ),
      timeSlots:
          (json['timeSlots'] as List<dynamic>?)
              ?.map((e) => TimeSlotModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DayGroupModelToJson(_DayGroupModel instance) =>
    <String, dynamic>{
      'days': instance.days.map((e) => _$WeekdayEnumMap[e]!).toList(),
      'headcountRuleModel': instance.headcountRuleModel.toJson(),
      'timeSlots': instance.timeSlots.map((e) => e.toJson()).toList(),
    };

const _$WeekdayEnumMap = {
  Weekday.monday: 1,
  Weekday.tuesday: 2,
  Weekday.wednesday: 3,
  Weekday.thursday: 4,
  Weekday.friday: 5,
  Weekday.saturday: 6,
  Weekday.sunday: 7,
  Weekday.holiday: 8,
};
