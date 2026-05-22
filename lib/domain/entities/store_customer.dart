import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/store_summary.dart';

part 'store_customer.freezed.dart';

@freezed
abstract class StoreCustomer with _$StoreCustomer {
  const factory StoreCustomer({
    required String id,
    required StoreSummary storeSummary,
    required String name,
    required String phone,
    required int totalSpent,
    required int visitCount,
    required DateTime lastReservationDate,
  }) = _StoreCustomer;
}
