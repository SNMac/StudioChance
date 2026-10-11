// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holiday_year_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HolidayYearModel _$HolidayYearModelFromJson(Map<String, dynamic> json) =>
    _HolidayYearModel(
      days: (json['days'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
    );

Map<String, dynamic> _$HolidayYearModelToJson(_HolidayYearModel instance) =>
    <String, dynamic>{'days': instance.days};
