// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReservationModel _$ReservationModelFromJson(Map<String, dynamic> json) =>
    _ReservationModel(
      id: json['id'] as String,
      storeId: json['storeId'] as String,
      writerId: json['writerId'] as String,
      status: $enumDecode(_$ReservationStatusEnumMap, json['status']),
      customerName: json['customerName'] as String,
      headCount: (json['headCount'] as num).toInt(),
      customerPhone: json['customerPhone'] as String,
      memo: json['memo'] as String,
      isAllDay: json['isAllDay'] as bool,
      startTime: const TimestampConverter().fromJson(
        json['startTime'] as Timestamp,
      ),
      endTime: const TimestampConverter().fromJson(
        json['endTime'] as Timestamp,
      ),
      platform: $enumDecode(_$ReservationPlatformEnumMap, json['platform']),
      paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['paymentMethod']),
      calculatedPrice: (json['calculatedPrice'] as num).toInt(),
      priceAdjustment: (json['priceAdjustment'] as num).toInt(),
      totalPrice: (json['totalPrice'] as num).toInt(),
    );

Map<String, dynamic> _$ReservationModelToJson(_ReservationModel instance) =>
    <String, dynamic>{
      'storeId': instance.storeId,
      'writerId': instance.writerId,
      'status': _$ReservationStatusEnumMap[instance.status]!,
      'customerName': instance.customerName,
      'headCount': instance.headCount,
      'customerPhone': instance.customerPhone,
      'memo': instance.memo,
      'isAllDay': instance.isAllDay,
      'startTime': const TimestampConverter().toJson(instance.startTime),
      'endTime': const TimestampConverter().toJson(instance.endTime),
      'platform': _$ReservationPlatformEnumMap[instance.platform]!,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'calculatedPrice': instance.calculatedPrice,
      'priceAdjustment': instance.priceAdjustment,
      'totalPrice': instance.totalPrice,
    };

const _$ReservationStatusEnumMap = {
  ReservationStatus.pending: 'PENDING',
  ReservationStatus.confirmed: 'CONFIRMED',
  ReservationStatus.canceled: 'CANCELED',
};

const _$ReservationPlatformEnumMap = {
  ReservationPlatform.naver: 'NAVER',
  ReservationPlatform.spaceCloud: 'SPACECLOUD',
  ReservationPlatform.yanolja: 'YANOLJA',
  ReservationPlatform.other: 'OTHER',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.onSite: 'ON_SITE',
  PaymentMethod.bankTransfer: 'BANK_TRANSFER',
  PaymentMethod.other: 'OTHER',
};
