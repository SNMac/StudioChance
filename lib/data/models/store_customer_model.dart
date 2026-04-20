import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/common/converters/timestamp_converter.dart';
import 'package:studio_chance/domain/entities/store_customer.dart';
import 'package:studio_chance/domain/entities/store_summary.dart';

part 'store_customer_model.freezed.dart';
part 'store_customer_model.g.dart';

@freezed
abstract class StoreCustomerModel with _$StoreCustomerModel {
  const StoreCustomerModel._();

  const factory StoreCustomerModel({
    @JsonKey(includeToJson: false) required String id,
    required String storeId,
    required String name,
    required String phone,
    // ⚠️ DataSource에서 FieldValue.increment()로만 업데이트. 직접 덮어쓰기 금지.
    required int totalSpent,
    // ⚠️ DataSource에서 FieldValue.increment()로만 업데이트. 직접 덮어쓰기 금지.
    required int visitCount,
    // ⚠️ DataSource에서 예약 startTime 기준으로만 업데이트.
    @TimestampConverter() required DateTime lastReservationDate,
  }) = _StoreCustomerModel;

  factory StoreCustomerModel.fromJson(Map<String, dynamic> json) =>
      _$StoreCustomerModelFromJson(json);

  factory StoreCustomerModel.fromEntity(StoreCustomer entity) {
    return StoreCustomerModel(
      id: entity.id,
      storeId: entity.storeSummary.id,
      name: entity.name,
      phone: entity.phone,
      totalSpent: entity.totalSpent,
      visitCount: entity.visitCount,
      lastReservationDate: entity.lastReservationDate,
    );
  }

  StoreCustomer toEntity(StoreSummary storeSummary) {
    return StoreCustomer(
      id: id,
      storeSummary: storeSummary,
      name: name,
      phone: phone,
      totalSpent: totalSpent,
      visitCount: visitCount,
      lastReservationDate: lastReservationDate,
    );
  }
}
