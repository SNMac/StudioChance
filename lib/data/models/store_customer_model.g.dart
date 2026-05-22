// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_customer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StoreCustomerModel _$StoreCustomerModelFromJson(Map<String, dynamic> json) =>
    _StoreCustomerModel(
      id: json['id'] as String,
      storeId: json['storeId'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      totalSpent: (json['totalSpent'] as num).toInt(),
      visitCount: (json['visitCount'] as num).toInt(),
      lastReservationDate: const TimestampConverter().fromJson(
        json['lastReservationDate'] as Timestamp,
      ),
    );

Map<String, dynamic> _$StoreCustomerModelToJson(_StoreCustomerModel instance) =>
    <String, dynamic>{
      'storeId': instance.storeId,
      'name': instance.name,
      'phone': instance.phone,
      'totalSpent': instance.totalSpent,
      'visitCount': instance.visitCount,
      'lastReservationDate': const TimestampConverter().toJson(
        instance.lastReservationDate,
      ),
    };
