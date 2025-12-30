// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_slot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimeSlot _$TimeSlotFromJson(Map<String, dynamic> json) => _TimeSlot(
  startTime: (json['startTime'] as num).toInt(),
  endTime: (json['endTime'] as num).toInt(),
  price: (json['price'] as num).toInt(),
  isHourly: json['isHourly'] as bool,
  isPerPerson: json['isPerPerson'] as bool,
);

Map<String, dynamic> _$TimeSlotToJson(_TimeSlot instance) => <String, dynamic>{
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'price': instance.price,
  'isHourly': instance.isHourly,
  'isPerPerson': instance.isPerPerson,
};
