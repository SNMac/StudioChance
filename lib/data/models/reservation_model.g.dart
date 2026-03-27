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
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      platform: json['platform'] as String,
      paymentMethod: json['paymentMethod'] as String,
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
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'platform': instance.platform,
      'paymentMethod': instance.paymentMethod,
      'calculatedPrice': instance.calculatedPrice,
      'priceAdjustment': instance.priceAdjustment,
      'totalPrice': instance.totalPrice,
    };

const _$ReservationStatusEnumMap = {
  ReservationStatus.pending: 'PENDING',
  ReservationStatus.confirmed: 'CONFIRMED',
  ReservationStatus.canceled: 'CANCELED',
};
