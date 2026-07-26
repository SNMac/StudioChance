// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_ocr_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReservationOcrResultModel _$ReservationOcrResultModelFromJson(
  Map<String, dynamic> json,
) => _ReservationOcrResultModel(
  platform: _parsePlatform(json['platform']),
  customerName: json['customerName'] as String?,
  customerPhone: json['customerPhone'] as String?,
  startTime: _parseDateTimeNullable(json['startTime']),
  endTime: _parseDateTimeNullable(json['endTime']),
  isAllDay: json['isAllDay'] as bool?,
  headCount: (json['headCount'] as num?)?.toInt(),
  memo: json['memo'] as String?,
  storeName: json['storeName'] as String?,
  spaceName: json['spaceName'] as String?,
);

Map<String, dynamic> _$ReservationOcrResultModelToJson(
  _ReservationOcrResultModel instance,
) => <String, dynamic>{
  'platform': _$ReservationPlatformEnumMap[instance.platform],
  'customerName': instance.customerName,
  'customerPhone': instance.customerPhone,
  'startTime': instance.startTime?.toIso8601String(),
  'endTime': instance.endTime?.toIso8601String(),
  'isAllDay': instance.isAllDay,
  'headCount': instance.headCount,
  'memo': instance.memo,
  'storeName': instance.storeName,
  'spaceName': instance.spaceName,
};

const _$ReservationPlatformEnumMap = {
  ReservationPlatform.naver: 'NAVER',
  ReservationPlatform.spaceCloud: 'SPACECLOUD',
  ReservationPlatform.yanolja: 'YANOLJA',
  ReservationPlatform.other: 'OTHER',
};
