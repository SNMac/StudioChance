// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_slot_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimeSlotModel _$TimeSlotModelFromJson(Map<String, dynamic> json) =>
    _TimeSlotModel(
      startTime: (json['startTime'] as num).toInt(),
      endTime: (json['endTime'] as num).toInt(),
      price: (json['price'] as num).toInt(),
      isHourly: json['isHourly'] as bool,
      isPerPerson: json['isPerPerson'] as bool,
    );

Map<String, dynamic> _$TimeSlotModelToJson(_TimeSlotModel instance) =>
    <String, dynamic>{
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'price': instance.price,
      'isHourly': instance.isHourly,
      'isPerPerson': instance.isPerPerson,
    };
