import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/domain/enums/reservation_status.dart';

part 'reservation_model.freezed.dart';
part 'reservation_model.g.dart';

@freezed
abstract class ReservationModel with _$ReservationModel {
  const ReservationModel._();

  const factory ReservationModel({
    @JsonKey(includeToJson: false) required String id,
    required String storeId,
    required String writerId,
    required ReservationStatus status,
    required String customerName,
    required int headCount,
    required String customerPhone,
    required String memo,
    required DateTime startTime,
    required DateTime endTime,
    required String platform,
    required String paymentMethod,
    required int calculatedPrice,
    required int priceAdjustment,
    required int totalPrice,
  }) = _ReservationModel;

  factory ReservationModel.fromJson(Map<String, dynamic> json) =>
      _$ReservationModelFromJson(json);

  factory ReservationModel.fromEntity(Reservation entity) {
    return ReservationModel(
      id: entity.id,
      storeId: entity.store.id,
      writerId: entity.writer.user.id,
      status: entity.status,
      customerName: entity.customerName,
      headCount: entity.headCount,
      customerPhone: entity.customerPhone,
      memo: entity.memo,
      startTime: entity.startTime,
      endTime: entity.endTime,
      platform: entity.platform,
      paymentMethod: entity.paymentMethod,
      calculatedPrice: entity.calculatedPrice,
      priceAdjustment: entity.priceAdjustment,
      totalPrice: entity.totalPrice,
    );
  }

  Reservation toEntity(Store store, StoreMemberInfo writer) {
    return Reservation(
      id: id,
      store: store,
      writer: writer,
      status: status,
      customerName: customerName,
      headCount: headCount,
      customerPhone: customerPhone,
      memo: memo,
      startTime: startTime,
      endTime: endTime,
      platform: platform,
      paymentMethod: paymentMethod,
      calculatedPrice: calculatedPrice,
      priceAdjustment: priceAdjustment,
      totalPrice: totalPrice,
    );
  }
}
